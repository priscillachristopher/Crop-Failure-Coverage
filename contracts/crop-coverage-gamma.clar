(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-already-exists (err u103))
(define-constant err-invalid-amount (err u104))
(define-constant err-policy-expired (err u105))
(define-constant err-already-claimed (err u106))
(define-constant err-no-payout-trigger (err u107))
(define-constant err-invalid-location (err u108))
(define-constant err-insufficient-funds (err u109))

(define-data-var oracle-address (optional principal) none)
(define-data-var policy-counter uint u0)
(define-data-var drought-threshold uint u21)
(define-data-var flood-threshold uint u150)
(define-data-var base-premium-rate uint u100)

(define-map policies
  uint
  {
    farmer: principal,
    farm-lat: int,
    farm-lng: int,
    coverage-amount: uint,
    premium-paid: uint,
    start-height: uint,
    end-height: uint,
    crop-type: (string-ascii 20),
    active: bool,
    claimed: bool
  }
)

(define-map weather-reports
  { lat: int, lng: int, height: uint }
  {
    consecutive-dry-days: uint,
    flood-risk-level: uint,
    temperature: int,
    precipitation: uint,
    reporter: principal
  }
)

(define-map farmer-policy-count
  principal
  uint
)

(define-public (set-oracle (oracle principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (var-set oracle-address (some oracle)))
  )
)

(define-public (update-thresholds (drought uint) (flood uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set drought-threshold drought)
    (var-set flood-threshold flood)
    (ok true)
  )
)

(define-public (create-policy 
  (farm-lat int)
  (farm-lng int)
  (coverage-amount uint)
  (policy-duration uint)
  (crop-type (string-ascii 20))
)
  (let
    (
      (policy-id (+ (var-get policy-counter) u1))
      (premium (calculate-premium coverage-amount policy-duration))
      (farmer tx-sender)
      (current-count (default-to u0 (map-get? farmer-policy-count farmer)))
    )
    (asserts! (> coverage-amount u0) err-invalid-amount)
    (asserts! (> policy-duration u0) err-invalid-amount)
    (asserts! (and (>= farm-lat -90000000) (<= farm-lat 90000000)) err-invalid-location)
    (asserts! (and (>= farm-lng -180000000) (<= farm-lng 180000000)) err-invalid-location)
    
    (try! (stx-transfer? premium farmer (as-contract tx-sender)))
    
    (map-set policies policy-id
      {
        farmer: farmer,
        farm-lat: farm-lat,
        farm-lng: farm-lng,
        coverage-amount: coverage-amount,
        premium-paid: premium,
        start-height: block-height,
        end-height: (+ block-height policy-duration),
        crop-type: crop-type,
        active: true,
        claimed: false
      }
    )
    
    (map-set farmer-policy-count farmer (+ current-count u1))
    (var-set policy-counter policy-id)
    (ok policy-id)
  )
)

(define-public (submit-weather-data
  (lat int)
  (lng int)
  (consecutive-dry-days uint)
  (flood-risk-level uint)
  (temperature int)
  (precipitation uint)
)
  (begin
    (asserts! (is-eq (some tx-sender) (var-get oracle-address)) err-unauthorized)
    (map-set weather-reports
      { lat: lat, lng: lng, height: block-height }
      {
        consecutive-dry-days: consecutive-dry-days,
        flood-risk-level: flood-risk-level,
        temperature: temperature,
        precipitation: precipitation,
        reporter: tx-sender
      }
    )
    (ok true)
  )
)

(define-public (claim-payout (policy-id uint))
  (let
    (
      (policy (unwrap! (map-get? policies policy-id) err-not-found))
      (farmer (get farmer policy))
      (farm-lat (get farm-lat policy))
      (farm-lng (get farm-lng policy))
    )
    (asserts! (is-eq tx-sender farmer) err-unauthorized)
    (asserts! (get active policy) err-policy-expired)
    (asserts! (<= block-height (get end-height policy)) err-policy-expired)
    (asserts! (not (get claimed policy)) err-already-claimed)
    
    (let
      (
        (weather (map-get? weather-reports { lat: farm-lat, lng: farm-lng, height: block-height }))
        (payout-triggered (check-payout-conditions weather))
      )
      (asserts! payout-triggered err-no-payout-trigger)
      
      (map-set policies policy-id (merge policy { claimed: true, active: false }))
      (try! (as-contract (stx-transfer? (get coverage-amount policy) tx-sender farmer)))
      (ok (get coverage-amount policy))
    )
  )
)

(define-public (cancel-expired-policy (policy-id uint))
  (let
    (
      (policy (unwrap! (map-get? policies policy-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get farmer policy)) err-unauthorized)
    (asserts! (> block-height (get end-height policy)) err-policy-expired)
    (asserts! (get active policy) err-already-claimed)
    
    (map-set policies policy-id (merge policy { active: false }))
    (ok true)
  )
)

(define-public (emergency-withdraw (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (as-contract (stx-transfer? amount tx-sender contract-owner)))
    (ok amount)
  )
)

(define-read-only (get-policy (policy-id uint))
  (map-get? policies policy-id)
)

(define-read-only (get-weather-report (lat int) (lng int) (height uint))
  (map-get? weather-reports { lat: lat, lng: lng, height: height })
)

(define-read-only (get-farmer-policy-count (farmer principal))
  (default-to u0 (map-get? farmer-policy-count farmer))
)

(define-read-only (get-contract-balance)
  (stx-get-balance (as-contract tx-sender))
)

(define-read-only (calculate-premium (coverage-amount uint) (duration uint))
  (let
    (
      (rate (var-get base-premium-rate))
      (amount-factor (/ coverage-amount u1000000))
      (duration-factor (/ duration u100))
    )
    (+ (* amount-factor rate) (* duration-factor u50))
  )
)

(define-read-only (check-payout-conditions (weather-data (optional {consecutive-dry-days: uint, flood-risk-level: uint, temperature: int, precipitation: uint, reporter: principal})))
  (match weather-data
    data
    (or
      (>= (get consecutive-dry-days data) (var-get drought-threshold))
      (>= (get flood-risk-level data) (var-get flood-threshold))
    )
    false
  )
)

(define-read-only (get-policy-status (policy-id uint))
  (match (map-get? policies policy-id)
    policy
    {
      exists: true,
      active: (get active policy),
      claimed: (get claimed policy),
      expired: (> block-height (get end-height policy)),
      farmer: (get farmer policy),
      coverage: (get coverage-amount policy)
    }
    {
      exists: false,
      active: false,
      claimed: false,
      expired: false,
      farmer: 'SP000000000000000000002Q6VF78,
      coverage: u0
    }
  )
)

(define-read-only (estimate-payout-eligibility 
  (lat int) 
  (lng int) 
  (current-height uint)
)
  (let
    (
      (weather (map-get? weather-reports { lat: lat, lng: lng, height: current-height }))
    )
    (check-payout-conditions weather)
  )
)

(define-read-only (get-oracle-address)
  (var-get oracle-address)
)

(define-read-only (get-thresholds)
  {
    drought-days: (var-get drought-threshold),
    flood-level: (var-get flood-threshold)
  }
)

(define-read-only (get-total-policies)
  (var-get policy-counter)
)