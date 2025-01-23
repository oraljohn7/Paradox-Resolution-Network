;; Paradox Resolution NFT Contract

(define-non-fungible-token paradox-resolution-nft uint)

(define-data-var token-id-counter uint u0)

(define-map token-metadata uint {
    resolver: principal,
    paradox-id: uint,
    resolution-id: uint,
    technique: (string-ascii 100),
    success-rate: uint,
    created-at: uint
})

(define-public (mint-resolution-nft (paradox-id uint) (resolution-id uint) (technique (string-ascii 100)) (success-rate uint))
    (let
        ((new-id (+ (var-get token-id-counter) u1)))
        (try! (nft-mint? paradox-resolution-nft new-id tx-sender))
        (map-set token-metadata new-id {
            resolver: tx-sender,
            paradox-id: paradox-id,
            resolution-id: resolution-id,
            technique: technique,
            success-rate: success-rate,
            created-at: block-height
        })
        (var-set token-id-counter new-id)
        (ok new-id)
    )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) (err u403))
        (nft-transfer? paradox-resolution-nft token-id sender recipient)
    )
)

(define-read-only (get-token-metadata (token-id uint))
    (map-get? token-metadata token-id)
)

(define-read-only (get-last-token-id)
    (var-get token-id-counter)
)

