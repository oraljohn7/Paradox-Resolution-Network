;; Collaborative Resolution Management Contract

(define-data-var resolution-counter uint u0)

(define-map resolutions uint {
    paradox-id: uint,
    resolver: principal,
    resolution-strategy: (string-utf8 1000),
    status: (string-ascii 20),
    resolved-at: uint
})

(define-public (propose-resolution (paradox-id uint) (resolution-strategy (string-utf8 1000)))
    (let
        ((new-id (+ (var-get resolution-counter) u1)))
        (map-set resolutions new-id {
            paradox-id: paradox-id,
            resolver: tx-sender,
            resolution-strategy: resolution-strategy,
            status: "proposed",
            resolved-at: u0
        })
        (var-set resolution-counter new-id)
        (ok new-id)
    )
)

(define-public (update-resolution-status (resolution-id uint) (new-status (string-ascii 20)))
    (let
        ((resolution (unwrap! (map-get? resolutions resolution-id) (err u404))))
        (asserts! (is-eq tx-sender (get resolver resolution)) (err u403))
        (ok (map-set resolutions resolution-id
            (merge resolution {
                status: new-status,
                resolved-at: (if (is-eq new-status "completed") block-height u0)
            })))
    )
)

(define-read-only (get-resolution (resolution-id uint))
    (map-get? resolutions resolution-id)
)

(define-read-only (get-resolution-count)
    (var-get resolution-counter)
)

