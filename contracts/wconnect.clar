;; Energy Trading Smart Contract

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-enough-balance (err u101))
(define-constant err-transfer-failed (err u102))
(define-constant err-invalid-price (err u103))
(define-constant err-invalid-amount (err u104))
(define-constant err-invalid-fee (err u105))

;; Define data variables
(define-data-var energy-price uint u100) ;; Price per kWh in microstacks (1 STX = 1,000,000 microstacks)
(define-data-var max-energy-per-user uint u10000) ;; Maximum energy a user can add (in kWh)
(define-data-var commission-rate uint u5) ;; Commission rate in percentage (e.g., 5 means 5%)

;; Define data maps
(define-map user-energy-balance principal uint)
(define-map user-stx-balance principal uint)

;; Private functions

;; Calculate commission
(define-private (calculate-commission (amount uint))
  (/ (* amount (var-get commission-rate)) u100))

;; Public functions

;; Set energy price (only contract owner)
(define-public (set-energy-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> new-price u0) err-invalid-price) ;; Ensure price is greater than 0
    (var-set energy-price new-price)
    (ok true)))

;; Set commission rate (only contract owner)
(define-public (set-commission-rate (new-rate uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-rate u100) err-invalid-fee) ;; Ensure rate is not more than 100%
    (var-set commission-rate new-rate)
    (ok true)))

;; Add energy to sell
(define-public (add-energy (amount uint))
  (let (
    (current-balance (default-to u0 (map-get? user-energy-balance tx-sender)))
    (new-balance (+ current-balance amount))
  )
    (asserts! (> amount u0) err-invalid-amount) ;; Ensure amount is greater than 0
    (asserts! (<= new-balance (var-get max-energy-per-user)) err-invalid-amount) ;; Ensure user doesn't exceed max energy limit
    (map-set user-energy-balance tx-sender new-balance)
    (ok true)))

;; Buy energy
(define-public (buy-energy (amount uint))
  (let (
    (energy-cost (* amount (var-get energy-price)))
    (commission (calculate-commission energy-cost))
    (total-cost (+ energy-cost commission))
    (seller-energy (default-to u0 (map-get? user-energy-balance contract-owner)))
    (buyer-balance (default-to u0 (map-get? user-stx-balance tx-sender)))
    (owner-balance (default-to u0 (map-get? user-stx-balance contract-owner)))
  )
    (asserts! (> amount u0) err-invalid-amount) ;; Ensure amount is greater than 0
    (asserts! (>= seller-energy amount) err-not-enough-balance)
    (asserts! (>= buyer-balance total-cost) err-not-enough-balance)
    
    ;; Update seller's energy balance
    (map-set user-energy-balance contract-owner (- seller-energy amount))
    
    ;; Update buyer's STX and energy balance
    (map-set user-stx-balance tx-sender (- buyer-balance total-cost))
    (map-set user-energy-balance tx-sender (+ (default-to u0 (map-get? user-energy-balance tx-sender)) amount))
    
    ;; Update contract owner's STX balance (energy cost + commission)
    (map-set user-stx-balance contract-owner (+ owner-balance total-cost))
    
    (ok true)))

;; Read-only functions

;; Get current energy price
(define-read-only (get-energy-price)
  (ok (var-get energy-price)))

;; Get current commission rate
(define-read-only (get-commission-rate)
  (ok (var-get commission-rate)))

;; Get user's energy balance
(define-read-only (get-energy-balance (user principal))
  (ok (default-to u0 (map-get? user-energy-balance user))))

;; Get user's STX balance
(define-read-only (get-stx-balance (user principal))
  (ok (default-to u0 (map-get? user-stx-balance user))))

;; Get maximum energy per user
(define-read-only (get-max-energy-per-user)
  (ok (var-get max-energy-per-user)))

;; Set maximum energy per user (only contract owner)
(define-public (set-max-energy-per-user (new-max uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> new-max u0) err-invalid-amount) ;; Ensure new max is greater than 0
    (var-set max-energy-per-user new-max)
    (ok true)))