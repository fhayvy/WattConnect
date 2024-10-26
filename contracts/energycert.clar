;; EnergyProduction - Energy Production Certification Contract
;; This contract works alongside WattConnect to verify and certify energy production

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u200))
(define-constant err-not-certified (err u201))
(define-constant err-already-certified (err u202))
(define-constant err-invalid-certifier (err u203))
(define-constant err-invalid-amount (err u204))
(define-constant err-not-authorized (err u205))

;; Define data variables
(define-data-var certification-fee uint u1000) ;; Fee in microstacks for certification
(define-data-var minimum-production uint u100) ;; Minimum energy production required (in kWh)

;; Define data maps
(define-map certified-producers principal bool)
(define-map authorized-certifiers principal bool)
(define-map producer-energy-data
    principal
    {
        total-production: uint,
        last-certification-date: uint,
        energy-source: (string-ascii 20),
        certification-status: bool
    })

;; Private functions
(define-private (is-authorized-certifier (certifier principal))
    (default-to false (map-get? authorized-certifiers certifier)))

;; Public functions

;; Add a new certifier (only contract owner)
(define-public (add-certifier (certifier principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set authorized-certifiers certifier true)
        (ok true)))

;; Remove a certifier (only contract owner)
(define-public (remove-certifier (certifier principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-delete authorized-certifiers certifier)
        (ok true)))

;; Apply for certification
(define-public (apply-for-certification (energy-amount uint) (energy-source (string-ascii 20)))
    (let (
        (producer-data (default-to 
            {
                total-production: u0,
                last-certification-date: u0,
                energy-source: "",
                certification-status: false
            }
            (map-get? producer-energy-data tx-sender)))
    )
        (asserts! (>= energy-amount (var-get minimum-production)) err-invalid-amount)
        (asserts! (not (get certification-status producer-data)) err-already-certified)
        
        (map-set producer-energy-data tx-sender
            {
                total-production: energy-amount,
                last-certification-date: block-height,
                energy-source: energy-source,
                certification-status: false
            })
        (ok true)))

;; Certify a producer (only authorized certifiers)
(define-public (certify-producer (producer principal))
    (let (
        (producer-data (default-to 
            {
                total-production: u0,
                last-certification-date: u0,
                energy-source: "",
                certification-status: false
            }
            (map-get? producer-energy-data producer)))
    )
        (asserts! (is-authorized-certifier tx-sender) err-invalid-certifier)
        (asserts! (not (get certification-status producer-data)) err-already-certified)
        
        ;; Update producer data with certification
        (map-set producer-energy-data producer
            {
                total-production: (get total-production producer-data),
                last-certification-date: block-height,
                energy-source: (get energy-source producer-data),
                certification-status: true
            })
        (map-set certified-producers producer true)
        (ok true)))

;; Revoke certification (only authorized certifiers)
(define-public (revoke-certification (producer principal))
    (begin
        (asserts! (is-authorized-certifier tx-sender) err-invalid-certifier)
        (asserts! (default-to false (map-get? certified-producers producer)) err-not-certified)
        
        (map-delete certified-producers producer)
        (map-set producer-energy-data producer
            {
                total-production: u0,
                last-certification-date: u0,
                energy-source: "",
                certification-status: false
            })
        (ok true)))

;; Read-only functions

;; Check if a producer is certified
(define-read-only (is-certified (producer principal))
    (ok (default-to false (map-get? certified-producers producer))))

;; Get producer data
(define-read-only (get-producer-data (producer principal))
    (ok (default-to
        {
            total-production: u0,
            last-certification-date: u0,
            energy-source: "",
            certification-status: false
        }
        (map-get? producer-energy-data producer))))

;; Get certification fee
(define-read-only (get-certification-fee)
    (ok (var-get certification-fee)))

;; Set certification fee (only contract owner)
(define-public (set-certification-fee (new-fee uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set certification-fee new-fee)
        (ok true)))

;; Set minimum production requirement (only contract owner)
(define-public (set-minimum-production (new-minimum uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set minimum-production new-minimum)
        (ok true)))