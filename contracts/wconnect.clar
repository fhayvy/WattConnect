;; Energy Trading Smart Contract

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-enough-balance (err u101))
(define-constant err-transfer-failed (err u102))

;; Define data variables
(define-data-var energy-price uint u100) ;; Price per kWh in microstacks (1 STX = 1,000,000 microstacks)

;; Define data maps
(define-map user-energy-balance principal uint)
(define-map user-stx-balance principal uint)

;; Public functions

;; Set energy price (only contract owner)
(define-public (set-energy-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set energy-price new-price)
    (ok true)))

;; Add energy to sell
(define-public (add-energy (amount uint))
  (let ((current-balance (default-to u0 (map-get? user-energy-balance tx-sender))))
    (map-set user-energy-balance tx-sender (+ current-balance amount))
    (ok true)))

;; Buy energy
(define-public (buy-energy (amount uint))
  (let (
    (total-cost (* amount (var-get energy-price)))
    (seller-energy (default-to u0 (map-get? user-energy-balance contract-owner)))
    (buyer-balance (default-to u0 (map-get? user-stx-balance tx-sender)))
  )
    (asserts! (>= seller-energy amount) err-not-enough-balance)
    (asserts! (>= buyer-balance total-cost) err-not-enough-balance)
    (map-set user-energy-balance contract-owner (- seller-energy amount))
    (map-set user-stx-balance tx-sender (- buyer-balance total-cost))
    (map-set user-stx-balance contract-owner (+ (default-to u0 (map-get? user-stx-balance contract-owner)) total-cost))
    (let ((buyer-energy (default-to u0 (map-get? user-energy-balance tx-sender))))
      (map-set user-energy-balance tx-sender (+ buyer-energy amount))
      (ok true))))

;; Read-only functions

;; Get current energy price
(define-read-only (get-energy-price)
  (ok (var-get energy-price)))

;; Get user's energy balance
(define-read-only (get-energy-balance (user principal))
  (ok (default-to u0 (map-get? user-energy-balance user))))

;; Get user's STX balance
(define-read-only (get-stx-balance (user principal))
  (ok (default-to u0 (map-get? user-stx-balance user))))