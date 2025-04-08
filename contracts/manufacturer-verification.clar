;; Manufacturer Verification Contract
;; Validates legitimate device producers in the medical industry

(define-data-var admin principal tx-sender)

;; Manufacturer data structure
(define-map manufacturers
  { id: (string-utf8 36) }  ;; UUID format
  {
    name: (string-utf8 100),
    address: (string-utf8 100),
    certification-id: (string-utf8 50),
    is-verified: bool,
    registration-date: uint
  }
)

;; Public function to register a new manufacturer (unverified initially)
(define-public (register-manufacturer
    (id (string-utf8 36))
    (name (string-utf8 100))
    (address (string-utf8 100))
    (certification-id (string-utf8 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-none (map-get? manufacturers { id: id })) (err u100))
    (ok (map-set manufacturers
      { id: id }
      {
        name: name,
        address: address,
        certification-id: certification-id,
        is-verified: false,
        registration-date: block-height
      }
    ))
  )
)

;; Verify a manufacturer
(define-public (verify-manufacturer (id (string-utf8 36)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (match (map-get? manufacturers { id: id })
      manufacturer (ok (map-set manufacturers
                        { id: id }
                        (merge manufacturer { is-verified: true })))
      (err u404)
    )
  )
)

;; Read-only function to check if a manufacturer is verified
(define-read-only (is-manufacturer-verified (id (string-utf8 36)))
  (match (map-get? manufacturers { id: id })
    manufacturer (get is-verified manufacturer)
    false
  )
)

;; Read-only function to get manufacturer details
(define-read-only (get-manufacturer (id (string-utf8 36)))
  (map-get? manufacturers { id: id })
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
