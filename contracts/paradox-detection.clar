;; Paradox Detection and Reporting Contract

(define-data-var paradox-counter uint u0)

(define-map paradoxes uint {
    reporter: principal,
    timeline-id: uint,
    description: (string-utf8 1000),
    severity: uint,
    status: (string-ascii 20),
    reported-at: uint
})

(define-public (report-paradox (timeline-id uint) (description (string-utf8 1000)) (severity uint))
    (let
        ((new-id (+ (var-get paradox-counter) u1)))
        (map-set paradoxes new-id {
            reporter: tx-sender,
            timeline-id: timeline-id,
            description: description,
            severity: severity,
            status: "reported",
            reported-at: block-height
        })
        (var-set paradox-counter new-id)
        (ok new-id)
    )
)

(define-public (update-paradox-status (paradox-id uint) (new-status (string-ascii 20)))
    (let
        ((paradox (unwrap! (map-get? paradoxes paradox-id) (err u404))))
        (asserts! (is-eq tx-sender (get reporter paradox)) (err u403))
        (ok (map-set paradoxes paradox-id
            (merge paradox { status: new-status })))
    )
)

(define-read-only (get-paradox (paradox-id uint))
    (map-get? paradoxes paradox-id)
)

(define-read-only (get-paradox-count)
    (var-get paradox-counter)
)

