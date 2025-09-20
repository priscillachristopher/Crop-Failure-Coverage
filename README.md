# 🌾 Crop Coverage Gamma

> Parametric crop insurance powered by satellite weather data - automatically triggered payouts for drought and flood protection

## 🎯 What is Crop Coverage Gamma?

A revolutionary smart contract that provides farmers with **parametric insurance** against crop failures. No complex claims process - payouts are automatically triggered when satellite/weather data confirms drought or flood conditions that threaten your crops.

## ✨ Key Features

- 🛰️ **Satellite Data Integration**: Real-time weather monitoring via trusted oracles
- 🌧️ **Drought Protection**: Auto-payout after 21+ consecutive dry days  
- 🌊 **Flood Coverage**: Auto-payout when flood risk levels reach 150+
- 📍 **GPS Precision**: Farm-specific coverage using exact lat/lng coordinates
- ⚡ **Instant Payouts**: No paperwork, no waiting - automated claim processing
- 🌱 **Multi-Crop Support**: Protection for corn, wheat, soybeans, rice, and more
- 💰 **Fair Pricing**: Dynamic premiums based on coverage amount and duration

## 🚀 Quick Start

### Prerequisites

- Clarinet CLI installed
- Stacks wallet with STX tokens
- Basic knowledge of smart contracts

### Deployment Steps

1. **Initialize Project**
   ```bash
   git clone your-repo
   cd Crop-Failure-Coverage
   clarinet check
   ```

2. **Deploy Contract**
   ```bash
   clarinet deploy
   ```

3. **Set Oracle (Owner Only)**
   ```clarity
   (contract-call? .crop-coverage-gamma set-oracle 'SP1WEATHER-ORACLE-ADDRESS)
   ```

## 📱 How to Use

### For Farmers 👨‍🌾

#### 1. Create Your Policy

```clarity
(contract-call? .crop-coverage-gamma create-policy
  farm-lat         ;; Your farm latitude (e.g., 40500000 = 40.5°N)
  farm-lng         ;; Your farm longitude (e.g., -95750000 = -95.75°W)  
  coverage-amount  ;; Coverage in microSTX (e.g., u10000000000 = 10,000 STX)
  policy-duration  ;; Duration in blocks (e.g., u1440 = ~10 days)
  crop-type       ;; Crop name (e.g., "corn", "wheat", "rice")
)
```

**Real Example:**
```clarity
(contract-call? .crop-coverage-gamma create-policy
  42000000      ;; Iowa farm: 42.0°N
  -93600000     ;; Iowa farm: -93.6°W
  u25000000000  ;; 25,000 STX coverage
  u4320         ;; 30 days coverage
  "corn"
)
```

#### 2. Monitor Your Policy

```clarity
;; Check policy details
(contract-call? .crop-coverage-gamma get-policy policy-id)

;; Check policy status
(contract-call? .crop-coverage-gamma get-policy-status policy-id)

;; See your total policies
(contract-call? .crop-coverage-gamma get-farmer-policy-count tx-sender)
```

#### 3. Claim Your Payout

```clarity
;; Automatically claim when conditions are met
(contract-call? .crop-coverage-gamma claim-payout policy-id)
```

### For Weather Oracles 🛰️

```clarity
(contract-call? .crop-coverage-gamma submit-weather-data
  lat                    ;; Farm latitude
  lng                    ;; Farm longitude
  consecutive-dry-days   ;; Days without precipitation
  flood-risk-level      ;; Flood risk score (0-300)
  temperature           ;; Temperature in celsius
  precipitation         ;; Precipitation in mm
)
```

## 🎮 Usage Examples

### Example 1: Corn Farmer in Iowa
```
🌽 Crop: Corn
📍 Location: Iowa (42.0°N, 93.6°W)
💰 Coverage: 25,000 STX
⏱️ Duration: 30 days
🌧️ Trigger: 21+ dry days OR flood risk 150+
💸 Premium: ~2,550 STX
```

### Example 2: Rice Farmer in Louisiana  
```
🌾 Crop: Rice
📍 Location: Louisiana (30.2°N, 92.0°W)
💰 Coverage: 50,000 STX
⏱️ Duration: 45 days  
🌊 Trigger: Flood risk 150+ OR 21+ dry days
💸 Premium: ~5,225 STX
```

## 🔧 Configuration

### Current Thresholds
- **Drought Trigger**: 21 consecutive dry days
- **Flood Trigger**: Risk level ≥ 150
- **Base Premium Rate**: 100 microSTX per million coverage

### Premium Formula
```
Premium = (Coverage ÷ 1M) × 100 + (Duration ÷ 100) × 50
```

### Geographic Limits
- **Latitude**: -90° to +90° (multiplied by 1M for precision)
- **Longitude**: -180° to +180° (multiplied by 1M for precision)

## 🔍 Contract Functions

### Public Functions

| Function | Access | Description |
|----------|--------|-----------|
| `create-policy` | Anyone | Create new crop insurance policy |
| `claim-payout` | Policy Owner | Claim payout when triggers are met |
| `cancel-expired-policy` | Policy Owner | Cancel expired policies |
| `submit-weather-data` | Oracle Only | Submit weather/satellite data |
| `set-oracle` | Owner Only | Set authorized weather oracle |
| `update-thresholds` | Owner Only | Update drought/flood thresholds |
| `emergency-withdraw` | Owner Only | Emergency fund withdrawal |

### Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-policy` | Get complete policy details |
| `get-policy-status` | Get policy status summary |
| `get-weather-report` | Get weather data for location/time |
| `calculate-premium` | Calculate premium for coverage parameters |
| `estimate-payout-eligibility` | Check if conditions trigger payout |
| `get-farmer-policy-count` | Get total policies for farmer |

## 🧪 Testing

```bash
# Syntax check
clarinet check

# Run tests
clarinet test

# Interactive testing
clarinet console
```

## 📊 Real-World Scenarios

### Drought Scenario ☀️
```
Day 1-20: Normal rainfall
Day 21: Drought threshold reached → Payout triggered
Oracle reports: consecutive-dry-days = 21
Result: Farmer receives full coverage amount
```

### Flood Scenario 🌊
```
Weather Alert: Heavy rainfall expected
Oracle reports: flood-risk-level = 165
Trigger: Risk > 150 threshold → Payout triggered  
Result: Farmer receives full coverage amount
```

## 🔐 Security Features

- ✅ **Oracle Authorization**: Only trusted weather oracles can submit data
- ✅ **Owner Controls**: Admin functions restricted to contract owner
- ✅ **Policy Validation**: Geographic and amount limits enforced
- ✅ **Double-Claim Prevention**: Each policy can only be claimed once
- ✅ **Time-Bound Policies**: Automatic expiration prevents indefinite coverage
- ✅ **Premium Pre-Payment**: Coverage only active after premium paid

## 🚧 Limitations & Future Enhancements

### Current Limitations
- Single oracle dependency
- Fixed threshold values
- No partial payouts
- No policy transfers

### Planned Features
- [ ] 🔄 Multiple oracle consensus
- [ ] 📈 Dynamic threshold adjustment
- [ ] 🎯 Partial payout calculations  
- [ ] 📱 Mobile app integration
- [ ] 🌍 Multi-region support
- [ ] 🏦 Reinsurance pools

## 🆘 Troubleshooting

### Common Issues

**Policy Creation Fails**
- Check STX balance for premium payment
- Verify latitude/longitude format (multiply by 1M)
- Ensure coverage amount > 0

**Claim Rejected**
- Verify weather conditions meet thresholds
- Check policy hasn't expired
- Confirm policy hasn't been claimed already

**Oracle Data Missing**
- Wait for next oracle update
- Contact oracle provider
- Check lat/lng coordinates match exactly

## 💡 Tips for Farmers

1. **📍 Precise Coordinates**: Use exact GPS coordinates of your most vulnerable fields
2. **⏰ Timing Matters**: Start policies before high-risk weather seasons
3. **💰 Coverage Planning**: Don't over-insure - calculate actual crop value
4. **📊 Monitor Weather**: Keep track of conditions to anticipate payouts
5. **🔄 Renewal Strategy**: Plan policy renewals for continuous coverage

## 📄 License

MIT License - Open source and free to use, modify, and distribute.



## 📞 Support

- 📧 Email: support@cropcoverage.gamma
- 🐛 Issues: [GitHub Issues](link-to-issues)
- 📖 Docs: [Documentation](link-to-docs)
- 💬 Community: [Discord](link-to-discord)

---

**Built with ❤️ for farmers worldwide** 🌍

*Protecting crops, securing livelihoods, one smart contract at a time.*

# 🌾 Crop Failure Coverage Smart Contract

A decentralized crop insurance platform built on Stacks blockchain using Clarity smart contracts. Get automated payouts for drought and flood conditions based on real weather data! 🌧️☀️

## 🚀 Features

- 📋 **Policy Creation**: Create customized crop insurance policies with location-based coverage
- 💰 **Automated Payouts**: Receive automatic compensation when weather conditions trigger claims
- 🌡️ **Weather Oracle Integration**: Real-time weather data processing for accurate assessments  
- 🏛️ **Manual Claims**: Submit manual claims for extreme weather events
- 💵 **Premium Management**: Transparent premium calculation and refund system
- 📊 **Multi-Policy Support**: Each farmer can hold up to 10 active policies

## 🛠️ Core Functions

### 🆕 Creating a Policy

```clarity
(create-policy coverage-amount premium duration-blocks latitude longitude crop-type)
```

**Parameters:**
- `coverage-amount`: Maximum payout amount (in microSTX)
- `premium`: Insurance premium payment (minimum 5% of coverage)
- `duration-blocks`: Policy validity period in blocks
- `latitude/longitude`: Farm location coordinates (scaled by 1000000)
- `crop-type`: Type of crop being insured (max 50 characters)

**Example:**
```clarity
(contract-call? .crop-insurance create-policy u10000000 u500000 u2016 i39740000 i-86130000 "corn")
```

### 🌦️ Weather Data Submission (Oracle Only)

```clarity
(submit-weather-data policy-id timestamp rainfall temperature drought-index flood-risk)
```

**Weather Thresholds:**
- 🏜️ **Severe Drought**: drought-index ≥ 90 → 100% payout
- 🌵 **Moderate Drought**: drought-index ≥ 80 → 80% payout  
- 🌊 **Severe Flood**: flood-risk ≥ 80 → 100% payout
- 💧 **Moderate Flood**: flood-risk ≥ 70 → 75% payout

### 📝 Manual Claims

```clarity
(manual-claim policy-id weather-timestamp)
```

Farmers can manually claim when:
- drought-index ≥ 60 OR flood-risk ≥ 50
- Policy is active and not expired
- Weather data exists for the timestamp

### ❌ Policy Cancellation

```clarity
(cancel-policy policy-id)
```

Cancel your policy early and receive 50% premium refund.

## 📖 Read-Only Functions

### 📄 View Policy Details
```clarity
(get-policy policy-id)
```

### 👨‍🌾 View Farmer's Policies
```clarity
(get-farmer-policies farmer-address)
```

### 🌡️ View Weather Data
```clarity
(get-weather-data policy-id timestamp)
```

### 💰 Contract Balance
```clarity
(get-contract-balance)
```

## 🏗️ Setup Instructions

### 1️⃣ Prerequisites
- Install [Clarinet](https://github.com/hirosystems/clarinet)
- Set up Stacks wallet

### 2️⃣ Deploy Contract
```bash
clarinet deploy --testnet
```

### 3️⃣ Fund Contract (Owner Only)
```clarity
(contract-call? .crop-insurance fund-contract u100000000)
```

### 4️⃣ Set Weather Oracle (Owner Only)  
```clarity
(contract-call? .crop-insurance set-oracle 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

## 💡 Usage Examples

### Creating Your First Policy 🌱
```clarity
;; Create a corn policy for $1000 coverage with $50 premium
(contract-call? .crop-insurance create-policy 
  u1000000000  ;; 1000 STX coverage
  u50000000    ;; 50 STX premium  
  u2016        ;; ~2 weeks duration
  i39740000    ;; Indianapolis latitude
  i-86130000   ;; Indianapolis longitude
  "corn"       ;; Crop type
)
```

### Checking Policy Status 📊
```clarity
;; View policy #1 details
(contract-call? .crop-insurance get-policy u1)

;; View all policies for a farmer
(contract-call? .crop-insurance get-farmer-policies 'SP1234...)
```

### Weather Oracle Data Submission 🌡️
```clarity
;; Oracle submits severe drought conditions
(contract-call? .crop-insurance submit-weather-data
  u1           ;; Policy ID
  u1640995200  ;; Timestamp
  u10          ;; 10mm rainfall
  u350         ;; 35°C temperature  
  u95          ;; 95% drought index (severe!)
  u20          ;; 20% flood risk
)
```

## 🔒 Security Features

- 🛡️ **Owner Controls**: Only contract owner can set oracle address
- 🔐 **Oracle Authentication**: Only authorized oracle can submit weather data
- 💸 **Automatic Payouts**: Trigger-based payouts reduce manipulation risk
- ⚖️ **Premium Validation**: Minimum 5% premium-to-coverage ratio
- 🚫 **Double Claim Prevention**: Policies can only be claimed once

## 🧪 Error Codes

| Code | Description |
|------|-------------|
| u100 | Unauthorized access |
| u101 | Policy already exists |
| u102 | Policy not found |
| u103 | Insufficient premium |
| u104 | Policy expired |
| u105 | Claim already processed |
| u106 | Invalid weather data |
| u107 | Insufficient contract balance |
| u108 | Policy inactive |

## 🌍 Weather Data Format

Weather data uses scaled integers:
- **Rainfall**: millimeters
- **Temperature**: degrees Celsius × 10
- **Drought Index**: 0-100 scale
- **Flood Risk**: 0-100 scale
- **Coordinates**: decimal degrees × 1,000,000

## 🚀 Future Enhancements

- 🛰️ Integration with satellite weather APIs
- 🤖 Machine learning-based payout calculations  
- 🌐 Multi-region weather data sources
- 📱 Mobile app for farmers
- 💎 NFT-based policy certificates

## 📝 License

MIT License - Build the future of decentralized agriculture insurance! 🌾✨
