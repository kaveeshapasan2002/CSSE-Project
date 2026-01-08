# Quick Start: Publish Your Healthcare API

## You Need to Publish First! 

You're currently in **Developer Portal** but your API isn't published yet.

---

## Step-by-Step (Do This Now):

### 1️⃣ Open Publisher Portal
```
https://localhost:9443/publisher
```
- Login: admin/admin

### 2️⃣ Import Your API
1. Click **"+ Create API"** button (top right)
2. Select **"Import OpenAPI"**
3. Click **"Browse File"** 
4. Navigate to and select:
   ```
   /Users/kaveeshaathukorala/github/CSSE-Project/backend/src/main/resources/api-definition.yaml
   ```
5. Click **"Next"** then **"Create"**

### 3️⃣ Configure Endpoint
1. Click **"Endpoints"** in left sidebar
2. **Production Endpoint**: `http://localhost:8080`
3. **Sandbox Endpoint**: `http://localhost:8080`
4. Click **"Save"**

### 4️⃣ Enable CORS (Important!)
1. Click **"Runtime"** in left sidebar
2. Find **"CORS Configuration"**
3. Enable CORS
4. **Access Control Allow Origins**: Add `http://localhost:5173`
5. **Access Control Allow Methods**: Select `GET, POST, PUT, DELETE, OPTIONS`
6. Click **"Save"**

### 5️⃣ Deploy the API
1. Click **"Deploy"** button (top right area)
2. Description: `Initial deployment`
3. Click **"Deploy"**
4. Wait for success message

### 6️⃣ Publish the API
1. Click **"Publish"** button (top right, next to Deploy)
2. Confirm the publish action
3. Wait for success message
4. ✅ Status should change to **PUBLISHED**

---

## Then Return to Developer Portal

After publishing, go back to:
```
https://localhost:9443/devportal
```

**Refresh the page** - You should now see:
- PizzaShackAPI (existing)
- **CSSE Healthcare API** ← Your new API!

---

## Alternative: Use the Automated Script

If you prefer automation, run:

```bash
cd /Users/kaveeshaathukorala/github/CSSE-Project/scripts
./publish-to-wso2.sh
```

This script will automatically:
- Import your API
- Configure endpoints
- Enable CORS
- Deploy and publish

---

## After Your API Appears in Developer Portal:

Then you can:
1. ✅ Click on "CSSE Healthcare API"
2. ✅ Click "Subscribe" button
3. ✅ Create application
4. ✅ Generate keys

---

## Need Help?

Detailed guides available:
- Full manual steps: `WSO2_MANUAL_PUBLISH_STEPS.md`
- Application creation: `WSO2_APPLICATION_CREATION_GUIDE.md`
- Complete integration: `WSO2_INTEGRATION_GUIDE.md`
