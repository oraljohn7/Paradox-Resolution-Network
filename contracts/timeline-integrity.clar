;; Timeline Integrity Maintenance Contract

(define-data-var timeline-counter uint u0)

(define-map timelines uint {
    creator: principal,
    description: (string-utf8 1000),
    integrity-score: uint,
    last-checked: uint
})

(define-public (register-timeline (description (string-utf8 1000)))
    (let
        ((new-id (+ (var-get timeline-counter) u1)))
        (map-set timelines new-id {
            creator: tx-sender,
            description: description,
            integrity-score: u100,
            last-checked: block-height
        })
        (var-set timeline-counter new-id)
        (ok new-id)
    )
)

(define-public (update-timeline-integrity (timeline-id uint) (new-score uint))
    (let
        ((timeline (unwrap! (map-get? timelines timeline-id) (err u404))))
        (asserts! (is-eq tx-sender (get creator timeline)) (err u403))
        (ok (map-set timelines timeline-id
            (merge timeline {
                integrity-score: new-score,
                last-checked: block-height
            })))
    )
)

(define-read-only (get-timeline (timeline-id uint))
    (map-get? timelines timeline-id)
)

(define-read-only (get-timeline-count)
    (var-get timeline-counter)
)

