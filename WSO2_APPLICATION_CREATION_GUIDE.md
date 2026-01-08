# WSO2 Developer Portal - Application Creation Guide

## You're Here: Create Application Form 📍

Looking at your screen, here's exactly what to do:

---

## Fill Out the Application Form

### 1. **Application Name** (Required - marked with *)
```
Enter: HealthcareFrontendApp
```
Or any name you prefer like:
- `MyHealthcareApp`
- `CSSE-Frontend`
- `HealthcareClient`

**Note**: This name will identify your application when managing API subscriptions.

---

### 2. **Shared Quota for Application Tokens** (Required - marked with *)
```
Select: 10PerMin (already shown in your dropdown)
```

**What does this mean?**
- This sets the rate limit for ALL APIs this application uses
- `10PerMin` = 10 API requests per minute
- Other options might include:
  - `20PerMin` - 20 requests per minute
  - `50PerMin` - 50 requests per minute
  - `Unlimited` - No rate limit (for testing)

**Recommendation**: 
- For testing/development: Use `Unlimited` or `50PerMin`
- For production: Use `10PerMin` or `20PerMin`

---

### 3. **Application Description** (Optional)
```
Enter: Frontend application for CSSE Healthcare Management System
```

Or something descriptive like:
- `React frontend app for managing healthcare operations`
- `Web application for doctors, staff, and admin users`

---

### 4. Click **SAVE** Button

After clicking SAVE, you'll be redirected to your new application's page.

---

## Next Step: Subscribe to Your API

After saving, you should see your application details page.

### Option A: Subscribe from Application Page

1. **Look for "Subscriptions" tab** in your application page
2. Click **"Subscribe to APIs"** or **"Subscribe"** button
3. You'll see a list of available APIs
4. Find **"CSSE Healthcare API"** (or your API name)
5. Select the **Throttling Policy**:
   ```
   Choose: 10PerMin (or Unlimited for testing)
   ```
6. Click **"Subscribe"**

### Option B: Subscribe from API Page

1. Go back to **"APIs"** menu (top navigation)
2. Click on your **"CSSE Healthcare API"**
3. You'll see API details with a **"Subscribe"** button on the left
4. Click **"Subscribe"**
5. A popup/form appears:
   - **Application**: Select `HealthcareFrontendApp` (your newly created app)
   - **Throttling Policy**: Choose `10PerMin` or `Unlimited`
6. Click **"Subscribe"**

✅ **Success Message**: "Subscribed Successfully" or similar

---

## Generate Keys (Most Important Step!)

### Step 1: Navigate to Your Application

1. Go to **"Applications"** menu (top navigation)
2. Click on your application: **"HealthcareFrontendApp"**

### Step 2: Go to Keys Section

You'll see tabs at the top:
- Overview
- **Production Keys** ← Click here
- Sandbox Keys
- Subscriptions
- OAuth2 Tokens

### Step 3: Generate Keys

On the **Production Keys** page, you'll see:

#### Option 1: Generate New Keys (Recommended for first time)

1. Click **"Generate Keys"** button
2. A form may appear with options:
   - **Grant Types**: 
     - ✅ Check: `Password` (for user login)
     - ✅ Check: `Refresh Token` (to refresh expired tokens)
     - ☐ Client Credentials (optional)
     - ☐ Code (optional)
   - **Callback URL**: Leave empty (not needed for password grant)
   - **Token Expiry**: `3600` seconds (1 hour) or adjust as needed

3. Click **"Generate"** or **"Submit"**

4. **You'll now see your credentials**:

```
┌─────────────────────────────────────────────────────┐
│ Consumer Key                                        │
│ abc123def456ghi789jkl012mno345pqr678stu901vwx234  │
│ [Copy icon]                                         │
├─────────────────────────────────────────────────────┤
│ Consumer Secret                                     │
│ xyz987uvw654rst321opq098lmn765kji432hgf109edc876  │
│ [Copy icon]                                         │
└─────────────────────────────────────────────────────┘
```

5. **🔴 CRITICAL**: Click the **copy icons** to copy both values!
   - Consumer Key = Your `CLIENT_ID`
   - Consumer Secret = Your `CLIENT_SECRET`

---

## What to Do with Your Keys

### Save Them Immediately!

Create a temporary note or file with:
```
WSO2 Credentials for HealthcareFrontendApp
==========================================
Consumer Key:    abc123def456ghi789jkl012mno345pqr678stu901vwx234
Consumer Secret: xyz987uvw654rst321opq098lmn765kji432hgf109edc876

Generated: 2026-01-05
Application: HealthcareFrontendApp
API: CSSE Healthcare API v1.0.0
```

⚠️ **Warning**: You can only see the Consumer Secret ONCE during generation. If you lose it, you'll need to regenerate keys.

---

## Update Your Frontend Configuration

### Step 1: Open the config file

Open: `frontend/src/config/wso2Config.js`

### Step 2: Replace the credentials

Find these lines:
```javascript
// Application credentials (from Developer Portal)
// TODO: Replace these with your actual credentials after creating application in WSO2
clientId: 'YOUR_CONSUMER_KEY',
clientSecret: 'YOUR_CONSUMER_SECRET',
```

Replace with your actual values:
```javascript
// Application credentials (from Developer Portal)
clientId: 'abc123def456ghi789jkl012mno345pqr678stu901vwx234',
clientSecret: 'xyz987uvw654rst321opq098lmn765kji432hgf109edc876',
```

### Step 3: Enable WSO2

Change this line:
```javascript
enabled: false,  // Set to true when you want to use WSO2 Gateway
```

To:
```javascript
enabled: true,  // WSO2 Gateway is now enabled!
```

### Step 4: Save the file

---

## Optional: Generate Access Token (for immediate testing)

If you want to test immediately without writing code:

### In the Developer Portal:

1. Still in **Production Keys** page
2. Scroll down to **"Generate Access Token"** section
3. Fill in:
   - **Scopes**: Leave empty or enter `default`
   - **Validity Period**: `3600` (1 hour)
4. Click **"Generate"**

5. **Copy the Access Token**:
```
eyJ4NXQiOiJNell4TW1Ga09HWXdNV0kwWldObU5EY3hOR1l3WW1NNFpUQTNNV0kyTkRBelpHUXpOR00wWkdSbE5qSmtPREZrWkRSaE9URmtNV0ZoTXpVMlpHVmxOZyIsImtpZCI6Ik16WXhNbUZrT0dZd01XSTBaV05tTkRjeE5HWXdZbU00WlRBM01XSTJOREF6WkdRek5HTTBaR1JsTmpKa09ERmtaRFJoT1RGa01XRmhNelUyWkdWbE5nX1JTMjU2IiwiYWxnIjoiUlMyNTYifQ...
```

6. **Test it with curl**:
```bash
curl -k -X GET https://localhost:8243/healthcare/1.0.0/api/doctors \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## Verification Checklist

Before moving forward, verify:

✅ Application created: `HealthcareFrontendApp`  
✅ Subscribed to: `CSSE Healthcare API`  
✅ Consumer Key copied  
✅ Consumer Secret copied  
✅ Keys saved securely  
✅ `wso2Config.js` updated with real credentials  
✅ `enabled: true` in config  

---

## Quick Test Command

Test your setup with this command (replace with your actual values):

```bash
# Replace YOUR_CLIENT_ID and YOUR_CLIENT_SECRET with your actual values
curl -k -X POST https://localhost:8243/token \
  -H "Authorization: Basic $(echo -n 'YOUR_CLIENT_ID:YOUR_CLIENT_SECRET' | base64)" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=admin@example.com&password=admin123&scope=default"
```

**Expected Response**:
```json
{
  "access_token": "eyJ4NXQiOiJNell4...",
  "refresh_token": "4d8f7e2a-1b3c...",
  "scope": "default",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

---

## Troubleshooting

### Problem: "Application name already exists"
**Solution**: Use a different name or delete the existing application first.

### Problem: Can't find API to subscribe
**Solution**: 
- Ensure your API is **PUBLISHED** (not just deployed)
- Check in Publisher Portal that lifecycle state = PUBLISHED
- Refresh Developer Portal page

### Problem: No "Generate Keys" button
**Solution**: 
- Make sure you're in the **Production Keys** tab
- Try using **Sandbox Keys** tab instead
- Refresh the page

### Problem: Lost Consumer Secret
**Solution**: 
- Go to Production Keys → Click **"Regenerate Consumer Secret"**
- Or delete and recreate keys entirely
- Update your frontend config with new values

---

## What's Next?

After completing these steps:

1. ✅ **Test with curl** (use command above)
2. ✅ **Start your frontend**: `cd frontend && npm run dev`
3. ✅ **Start your backend**: `cd backend && ./gradlew bootRun`
4. ✅ **Test login** through your React app
5. ✅ **Monitor in WSO2**: Check analytics at https://localhost:9443/analytics

---

## Summary: What You Just Did

```
1. Created Application (HealthcareFrontendApp)
   ↓
2. Subscribed to API (CSSE Healthcare API)
   ↓
3. Generated OAuth2 Credentials
   ↓
4. Got Consumer Key & Secret
   ↓
5. Updated frontend/src/config/wso2Config.js
   ↓
6. Ready to use WSO2 API Gateway! 🎉
```

Your requests now flow:
```
Frontend → WSO2 Gateway → Backend
          ↑
    (with rate limiting,
     authentication,
     monitoring)
```

Good luck! 🚀
