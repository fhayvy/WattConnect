;; Energy Trading Smart Contract

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-enough-balance (err u101))
(define-constant err-transfer-failed (err u102))
(define-constant err-invalid-price (err u103))
(define-constant err-invalid-amount (err u104))

;; Define data variables
(define-data-var energy-price uint u100) ;; Price per kWh in microstacks (1 STX = 1,000,000 microstacks)
(define-data-var max-energy-per-user uint u10000) ;; Maximum energy a user can add (in kWh)

;; Define data maps
(define-map user-energy-balance principal uint)
(define-map user-stx-balance principal uint)

;; Public functions

;; Set energy price (only contract owner)
(define-public (set-energy-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> new-price u0) err-invalid-price) ;; Ensure price is greater than 0
    (var-set energy-price new-price)
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
    (total-cost (* amount (var-get energy-price)))
    (seller-energy (default-to u0 (map-get? user-energy-balance contract-owner)))
    (buyer-balance (default-to u0 (map-get? user-stx-balance tx-sender)))
  )
    (asserts! (> amount u0) err-invalid-amount) ;; Ensure amount is greater than 0
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