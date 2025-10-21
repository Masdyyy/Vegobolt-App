# 🧪 Forgot Password - Testing Guide

## 📋 Test Cases

### Test Case 1: Valid Email - Happy Path ✅

**Preconditions:**
- User exists in database with email: `test@example.com`
- Backend server is running
- Email service is configured

**Steps:**
1. Open app and go to Login page
2. Click "Forgot Password?"
3. Enter email: `test@example.com`
4. Click "Continue"

**Expected Results:**
- ✅ Loading indicator appears
- ✅ Success message: "Password reset link sent..."
- ✅ Navigate back to login page
- ✅ Email received in inbox
- ✅ Email contains reset link

**Status:** 🟢 PASS / 🔴 FAIL

---

### Test Case 2: Invalid Email Format ❌

**Steps:**
1. Go to Forgot Password page
2. Enter invalid email: `notanemail`
3. Click "Continue"

**Expected Results:**
- ✅ Form validation error
- ✅ Message: "Please enter a valid email"
- ✅ No API call made

**Status:** 🟢 PASS / 🔴 FAIL

---

### Test Case 3: Empty Email Field ❌

**Steps:**
1. Go to Forgot Password page
2. Leave email field empty
3. Click "Continue"

**Expected Results:**
- ✅ Form validation error
- ✅ Message: "Please enter your email"
- ✅ No API call made

**Status:** 🟢 PASS / 🔴 FAIL

---

### Test Case 4: Non-Existent Email 🔒

**Steps:**
1. Go to Forgot Password page
2. Enter email: `doesnotexist@example.com`
3. Click "Continue"

**Expected Results:**
- ✅ Success message (for security - don't reveal if user exists)
- ✅ No email sent
- ✅ No error displayed

**Status:** 🟢 PASS / 🔴 FAIL

---

### Test Case 5: Reset Password with Valid Token ✅

**Preconditions:**
- Have a valid reset token from email

**Steps:**
1. Click reset link from email
2. Enter new password: `newPassword123`
3. Confirm password: `newPassword123`
4. Click "Reset Password"

**Expected Results:**
- ✅ Loading indicator appears
- ✅ Success message: "Password has been reset..."
- ✅ Redirect to login page
- ✅ Can login with new password
- ✅ Old password no longer works

**Status:** 🟢 PASS / 🔴 FAIL

---

### Test Case 6: Reset Password with Expired Token ⏱️

**Preconditions:**
- Have a token that's older than 1 hour

**Steps:**
1. Use expired token
2. Try to reset password

**Expected Results:**
- ✅ Error message: "Invalid or expired reset token"
- ✅ Password not changed
- ✅ Suggest requesting new link

**Status:** 🟢 PASS / 🔴 FAIL

---

### Test Case 7: Password Too Short ❌

**Steps:**
1. On reset password page
2. Enter password: `123` (less than 6 chars)
3. Confirm password: `123`
4. Click "Reset Password"

**Expected Results:**
- ✅ Form validation error
- ✅ Message: "Password must be at least 6 characters"
- ✅ No API call made

**Status:** 🟢 PASS / 🔴 FAIL

---

### Test Case 8: Passwords Don't Match ❌

**Steps:**
1. On reset password page
2. Enter password: `password123`
3. Confirm password: `password456`
4. Click "Reset Password"

**Expected Results:**
- ✅ Form validation error
- ✅ Message: "Passwords do not match"
- ✅ No API call made

**Status:** 🟢 PASS / 🔴 FAIL

---

### Test Case 9: Network Error 🌐

**Preconditions:**
- Backend server is not running OR no internet connection

**Steps:**
1. Go to Forgot Password page
2. Enter valid email
3. Click "Continue"

**Expected Results:**
- ✅ Error message: "Network error: ..."
- ✅ User informed of the issue
- ✅ Can retry

**Status:** 🟢 PASS / 🔴 FAIL

---

### Test Case 10: Email Service Failure 📧

**Preconditions:**
- Email credentials are invalid/expired

**Steps:**
1. Request password reset
2. Backend tries to send email

**Expected Results:**
- ✅ Error logged on server
- ✅ User sees error message
- ✅ Token still saved (user can manually use it)

**Status:** 🟢 PASS / 🔴 FAIL

---

## 🔄 Integration Test Scenarios

### Scenario A: Complete Flow Test

**Steps:**
1. ✅ Register new user
2. ✅ Logout
3. ✅ Request password reset
4. ✅ Check email
5. ✅ Click reset link
6. ✅ Enter new password
7. ✅ Login with new password
8. ✅ Verify dashboard access

**Expected:** All steps complete successfully

---

### Scenario B: Multiple Reset Requests

**Steps:**
1. ✅ Request reset for user@example.com
2. ✅ Wait 5 seconds
3. ✅ Request reset again for same email
4. ✅ Check if both emails received
5. ✅ Try first token
6. ✅ Try second token

**Expected:** Both tokens work (until expiration)

---

### Scenario C: Token Reuse Prevention

**Steps:**
1. ✅ Request password reset
2. ✅ Use token to reset password
3. ✅ Try to use same token again

**Expected:** Second attempt fails (token cleared)

---

## 🧪 API Test Cases

### API Test 1: Request Reset - Valid Email

```bash
curl -X POST http://localhost:3000/api/auth/password-reset \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "If the email exists, a password reset link will be sent"
}
```

---

### API Test 2: Request Reset - Missing Email

```bash
curl -X POST http://localhost:3000/api/auth/password-reset \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Expected Response:**
```json
{
  "success": false,
  "message": "Please provide email"
}
```

---

### API Test 3: Reset Password - Valid Token

```bash
curl -X POST http://localhost:3000/api/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{"token":"YOUR_TOKEN","newPassword":"newPassword123"}'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Password has been reset successfully..."
}
```

---

### API Test 4: Reset Password - Invalid Token

```bash
curl -X POST http://localhost:3000/api/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{"token":"invalid_token","newPassword":"newPassword123"}'
```

**Expected Response:**
```json
{
  "success": false,
  "message": "Invalid or expired reset token"
}
```

---

### API Test 5: Reset Password - Short Password

```bash
curl -X POST http://localhost:3000/api/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{"token":"YOUR_TOKEN","newPassword":"123"}'
```

**Expected Response:**
```json
{
  "success": false,
  "message": "Password must be at least 6 characters long"
}
```

---

## 🔍 Database Verification Tests

### Verify Token Storage

```javascript
// MongoDB Shell
db.users.findOne({ email: "test@example.com" }, {
  passwordResetToken: 1,
  passwordResetExpires: 1
})
```

**Expected Result:**
```json
{
  "passwordResetToken": "a1b2c3d4...",
  "passwordResetExpires": ISODate("2025-10-21T15:30:00.000Z")
}
```

---

### Verify Token Cleanup

```javascript
// After successful reset
db.users.findOne({ email: "test@example.com" }, {
  passwordResetToken: 1,
  passwordResetExpires: 1
})
```

**Expected Result:**
```json
{
  "passwordResetToken": null,
  "passwordResetExpires": null
}
```

---

### Verify Password Hash Updated

```javascript
// Check password field changed
db.users.findOne({ email: "test@example.com" }, {
  password: 1,
  updatedAt: 1
})
```

**Expected:** Password hash is different, updatedAt is recent

---

## 📱 UI/UX Test Cases

### UI Test 1: Loading States

**Steps:**
1. Click "Continue" on forgot password page
2. Observe UI during API call

**Expected:**
- ✅ Button shows loading spinner
- ✅ Button is disabled
- ✅ Cannot submit twice
- ✅ Loading stops after response

---

### UI Test 2: Error Messages

**Steps:**
1. Trigger various errors
2. Check error display

**Expected:**
- ✅ Errors shown in SnackBar
- ✅ Red background for errors
- ✅ Clear error messages
- ✅ Errors auto-dismiss

---

### UI Test 3: Success Messages

**Steps:**
1. Complete successful reset request
2. Check success message

**Expected:**
- ✅ Success shown in SnackBar
- ✅ Green background for success
- ✅ Clear success message
- ✅ Navigate to appropriate page

---

### UI Test 4: Form Validation Visual Feedback

**Steps:**
1. Enter invalid data
2. Try to submit
3. Observe validation feedback

**Expected:**
- ✅ Red border on invalid fields
- ✅ Error text below fields
- ✅ Clear what needs fixing
- ✅ Validates on blur/change

---

### UI Test 5: Password Visibility Toggle

**Steps:**
1. On reset password page
2. Click eye icon

**Expected:**
- ✅ Password visible when clicked
- ✅ Icon changes (eye → eye-off)
- ✅ Works for both password fields
- ✅ Independent toggles

---

## ⚡ Performance Tests

### Performance Test 1: API Response Time

**Steps:**
1. Measure API call duration
2. For both endpoints

**Expected:**
- ✅ Request reset: < 2 seconds
- ✅ Reset password: < 1 second
- ✅ Acceptable on slow networks

---

### Performance Test 2: Email Delivery Time

**Steps:**
1. Request reset
2. Measure time until email received

**Expected:**
- ✅ Email arrives within 30 seconds
- ✅ Acceptable delay on Gmail

---

## 🔐 Security Tests

### Security Test 1: Token Randomness

**Steps:**
1. Generate 10 tokens
2. Compare for patterns

**Expected:**
- ✅ All tokens unique
- ✅ No predictable patterns
- ✅ 64 characters long

---

### Security Test 2: Password Hashing

**Steps:**
1. Reset password to "password123"
2. Check database

**Expected:**
- ✅ Password not stored as plain text
- ✅ Bcrypt hash format
- ✅ Includes salt

---

### Security Test 3: User Enumeration Prevention

**Steps:**
1. Request reset for existing user
2. Request reset for non-existing user
3. Compare responses

**Expected:**
- ✅ Same response message
- ✅ Same response time (approximately)
- ✅ No way to tell if user exists

---

## 📊 Test Results Template

| Test Case | Status | Notes | Date Tested |
|-----------|--------|-------|-------------|
| TC1: Valid Email | 🟢 | All good | 2025-10-21 |
| TC2: Invalid Format | 🟢 | Validation works | 2025-10-21 |
| TC3: Empty Field | 🟢 | Catches empty input | 2025-10-21 |
| TC4: Non-existent Email | 🟢 | Security maintained | 2025-10-21 |
| TC5: Valid Token Reset | 🟢 | Password updated | 2025-10-21 |
| TC6: Expired Token | 🟢 | Properly rejected | 2025-10-21 |
| TC7: Short Password | 🟢 | Min length enforced | 2025-10-21 |
| TC8: Password Mismatch | 🟢 | Validation works | 2025-10-21 |
| TC9: Network Error | 🟢 | Error handled | 2025-10-21 |
| TC10: Email Failure | 🟡 | Needs monitoring | 2025-10-21 |

**Legend:**
- 🟢 PASS - Test passed
- 🟡 PARTIAL - Works but has issues
- 🔴 FAIL - Test failed
- ⚪ SKIP - Not tested yet

---

## 🎯 Testing Checklist

### Pre-Testing Setup
- [ ] Backend server running
- [ ] Database accessible
- [ ] Email service configured
- [ ] Test user created
- [ ] Flutter app compiled

### Functional Tests
- [ ] Request reset (valid email)
- [ ] Request reset (invalid email)
- [ ] Request reset (empty field)
- [ ] Reset password (valid token)
- [ ] Reset password (expired token)
- [ ] Reset password (short password)
- [ ] Reset password (mismatch)
- [ ] Login with new password
- [ ] Login with old password (should fail)

### UI/UX Tests
- [ ] Loading states display
- [ ] Error messages clear
- [ ] Success messages visible
- [ ] Form validation works
- [ ] Password visibility toggle
- [ ] Navigation flows correct

### Security Tests
- [ ] Tokens are random
- [ ] Passwords are hashed
- [ ] User enumeration prevented
- [ ] Token expiration works
- [ ] Token cleanup happens

### Performance Tests
- [ ] API responds quickly
- [ ] Email delivered timely
- [ ] No memory leaks
- [ ] Handles concurrent requests

### Edge Cases
- [ ] Multiple reset requests
- [ ] Token reuse attempts
- [ ] Special characters in password
- [ ] Very long passwords
- [ ] Network interruptions

---

## 📝 Bug Report Template

```markdown
## Bug Report

**Title:** [Short description]

**Severity:** Critical / High / Medium / Low

**Steps to Reproduce:**
1. 
2. 
3. 

**Expected Result:**


**Actual Result:**


**Environment:**
- Device: 
- OS: 
- App Version: 
- Backend Version: 

**Screenshots/Logs:**


**Additional Notes:**

```

---

## ✅ Sign-Off Criteria

Before marking as production-ready:

- [ ] All test cases pass
- [ ] No critical/high bugs
- [ ] Performance acceptable
- [ ] Security verified
- [ ] Documentation complete
- [ ] Code reviewed
- [ ] Stakeholder approval

---

**Testing Completed By:** _______________

**Date:** _______________

**Status:** ⚪ Not Started / 🟡 In Progress / 🟢 Completed / 🔴 Issues Found
