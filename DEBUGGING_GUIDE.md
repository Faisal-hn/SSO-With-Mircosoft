# Microsoft SSO Debugging Guide for Cursor IDE

## 🎯 Overview

This guide will help you debug the Microsoft Entra ID OAuth2 authentication flow in your Spring Boot application using Cursor IDE.

## 🔍 Key Spring Security Components in OAuth2 Flow

### 1. **OAuth2 Authorization Request (Step 1)**
When user clicks "Sign Up with Microsoft", these components handle the redirect:

#### **Key Classes to Debug:**
- `OAuth2AuthorizationRequestRedirectFilter` - Handles `/oauth2/authorization/azure`
- `DefaultOAuth2AuthorizationRequestResolver` - Builds the authorization URL
- `OAuth2AuthorizationRequest` - Contains state, nonce, scopes

#### **Key Methods to Breakpoint:**
```java
// File: OAuth2AuthorizationRequestRedirectFilter.java
public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)

// File: DefaultOAuth2AuthorizationRequestResolver.java  
public OAuth2AuthorizationRequest resolve(HttpServletRequest request)
```

### 2. **Authorization Code Reception (Step 2)**
When Microsoft redirects back with authorization code:

#### **Key Classes to Debug:**
- `OAuth2LoginAuthenticationFilter` - Processes `/login/oauth2/code/azure`
- `OAuth2LoginAuthenticationProvider` - Orchestrates authentication
- `OidcAuthorizationCodeAuthenticationProvider` - Handles OIDC flow

#### **Key Methods to Breakpoint:**
```java
// File: OAuth2LoginAuthenticationFilter.java
public Authentication attemptAuthentication(HttpServletRequest request, HttpServletResponse response)

// File: OAuth2LoginAuthenticationProvider.java
public Authentication authenticate(Authentication authentication)
```

### 3. **Token Exchange (Step 3)**
Converting authorization code to access token:

#### **Key Classes to Debug:**
- `DefaultAuthorizationCodeTokenResponseClient` - Makes token request to Microsoft
- `OAuth2AccessTokenResponseHttpMessageConverter` - Parses token response

#### **Key Methods to Breakpoint:**
```java
// File: DefaultAuthorizationCodeTokenResponseClient.java
public OAuth2AccessTokenResponse getTokenResponse(OAuth2AuthorizationCodeGrantRequest authorizationCodeGrantRequest)
```

### 4. **User Information Retrieval (Step 4)**
Getting user details from Microsoft Graph:

#### **Key Classes to Debug:**
- `DefaultOAuth2UserService` - Fetches user info
- `OidcUserService` - Handles OIDC user info
- `DefaultOAuth2User` - User object creation

#### **Key Methods to Breakpoint:**
```java
// File: DefaultOAuth2UserService.java
public OAuth2User loadUser(OAuth2UserRequest userRequest)

// File: OidcUserService.java
public OidcUser loadUser(OidcUserRequest userRequest)
```

## 🛠️ Setting Up Debugging in Cursor IDE

### Step 1: Load Environment Variables
Make sure your `.env` file exists with your Azure credentials:
```bash
# Check if .env file exists
ls -la .env
```

### Step 2: Open Debug Panel
1. Press `Ctrl+Shift+D` (or `Cmd+Shift+D` on Mac)
2. Select "Debug Spring Boot App" configuration
3. Click the green play button

### Step 3: Alternative - Debug with Maven
You can also run the debug task:
1. Press `Ctrl+Shift+P` (Command Palette)
2. Type "Tasks: Run Task"
3. Select "run-spring-boot-debug"

## 🎯 Critical Breakpoints to Set

### A. **Your Application Code** (Easy to understand)

#### 1. AuthController.java
```java
// Line ~25: When user clicks signup
@GetMapping("/signup")
public String signUp(@RequestParam(value = "error", required = false) String error, Model model) {
    // SET BREAKPOINT HERE
    if (error != null) {
        model.addAttribute("error", "Sign up failed. Please try again.");
    }
    model.addAttribute("isSignup", true);
    return "auth";
}

// Line ~43: After successful authentication  
@GetMapping("/dashboard")
public String dashboard(@AuthenticationPrincipal OAuth2User principal, Model model) {
    // SET BREAKPOINT HERE
    if (principal != null) {
        model.addAttribute("name", principal.getAttribute("name"));
        model.addAttribute("email", principal.getAttribute("email"));
        model.addAttribute("attributes", principal.getAttributes());
    }
    return "dashboard";
}
```

#### 2. SecurityConfig.java
```java
// Line ~15: Security configuration
@Bean
public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    // SET BREAKPOINT HERE
    http.authorizeHttpRequests(authz -> authz
        .requestMatchers("/", "/signup", "/signin", "/css/**", "/js/**", "/images/**", "/h2-console/**").permitAll()
        .anyRequest().authenticated()
    )
    .oauth2Login(oauth2 -> oauth2
        .loginPage("/signin")
        .defaultSuccessUrl("/dashboard", true)  // SET BREAKPOINT HERE TOO
        .failureUrl("/signin?error=true")
    );
    return http.build();
}
```

### B. **Spring Security Internal Classes** (Advanced debugging)

To debug Spring Security internals, you'll need to:

1. **Add Spring Security Source to Classpath** (in Cursor IDE):
   - Go to `Command Palette` → `Java: Clean Workspace`
   - Let Cursor re-index with sources

2. **Set Breakpoints in Spring Security Classes**:

#### OAuth2 Authorization Request
```java
// Class: org.springframework.security.oauth2.client.web.OAuth2AuthorizationRequestRedirectFilter
// Method: doFilter() - around line 150
if (this.authorizationRequestMatcher.matches(request)) {
    // SET BREAKPOINT HERE
    this.requestCache.saveRequest(request, response);
    this.authorizationRequestResolver.resolve(request);
}
```

#### Token Exchange
```java
// Class: org.springframework.security.oauth2.client.endpoint.DefaultAuthorizationCodeTokenResponseClient  
// Method: getTokenResponse() - around line 80
public OAuth2AccessTokenResponse getTokenResponse(OAuth2AuthorizationCodeGrantRequest authorizationCodeGrantRequest) {
    // SET BREAKPOINT HERE
    RequestEntity<?> request = this.requestEntityConverter.convert(authorizationCodeGrantRequest);
    ResponseEntity<OAuth2AccessTokenResponse> response = this.restOperations.exchange(request, OAuth2AccessTokenResponse.class);
    return response.getBody();
}
```

## 🚀 How to Debug the Flow

### Step 1: Start Debugging
1. Set breakpoints in `AuthController.signup()` method
2. Start the debugger (F5 or click Debug)
3. Open browser to `http://localhost:8080`
4. Click "Sign Up"

### Step 2: Follow the Flow
You'll hit breakpoints in this order:

1. **Your AuthController** → signup() method
2. **OAuth2AuthorizationRequestRedirectFilter** → User redirected to Microsoft
3. **[User authenticates with Microsoft]**
4. **OAuth2LoginAuthenticationFilter** → Microsoft redirects back with code
5. **DefaultAuthorizationCodeTokenResponseClient** → Code exchanged for token
6. **DefaultOAuth2UserService** → User info retrieved
7. **Your AuthController** → dashboard() method

### Step 3: Inspect Variables
At each breakpoint, inspect these key variables:

#### In AuthController:
- `error` parameter
- `model` attributes
- `principal` object and its attributes

#### In Spring Security classes:
- `OAuth2AuthorizationRequest` - state, nonce, scopes
- `OAuth2AccessTokenResponse` - access_token, id_token
- `OAuth2User` - user attributes from Microsoft

## 🔧 Debugging Tips

### 1. **Watch OAuth2 User Attributes**
```java
// In dashboard() method, add to watch:
principal.getAttributes().get("email")
principal.getAttributes().get("name") 
principal.getAttributes().get("sub")
principal.getAuthorities()
```

### 2. **Monitor HTTP Requests**
Enable detailed logging in `application.yml`:
```yaml
logging:
  level:
    org.springframework.security: DEBUG
    org.springframework.security.oauth2: TRACE
    org.springframework.web: DEBUG
    org.apache.http: DEBUG
```

### 3. **Debug Security Context**
```java
// Add this to any method to see security context:
SecurityContext context = SecurityContextHolder.getContext();
Authentication auth = context.getAuthentication();
// Inspect 'auth' object
```

### 4. **Network Traffic Analysis**
- Open browser Developer Tools (F12)
- Go to Network tab
- Monitor requests to:
  - `/oauth2/authorization/azure`
  - `/login/oauth2/code/azure`
  - Microsoft endpoints

## 🚨 Common Issues to Debug

### 1. **Redirect URI Mismatch**
**Symptom**: Error "AADSTS50011: Invalid redirect URI"
**Debug**: Check `OAuth2AuthorizationRequest.redirectUri`
**Fix**: Ensure Azure AD has `http://localhost:8080/login/oauth2/code/azure`

### 2. **State Parameter Mismatch**  
**Symptom**: Authentication fails silently
**Debug**: Compare `state` in request vs. response
**Fix**: Check session management

### 3. **Token Exchange Failure**
**Symptom**: Error after Microsoft redirect
**Debug**: Breakpoint in `DefaultAuthorizationCodeTokenResponseClient`
**Check**: Client ID, Client Secret, Tenant ID

### 4. **User Info Retrieval Failure**
**Symptom**: Authentication succeeds but user data missing
**Debug**: Breakpoint in `DefaultOAuth2UserService.loadUser()`
**Check**: Scopes, Graph API permissions

## 📱 Quick Debug Session Example

1. **Set breakpoint** in `AuthController.signup()`
2. **Start debugger** (F5)
3. **Open browser** → `http://localhost:8080`
4. **Click "Sign Up"** → Hits your breakpoint
5. **Step through** (F10) → See model being populated
6. **Continue** (F5) → Redirected to Microsoft
7. **Login with Microsoft** → 
8. **Breakpoint hits** in Spring Security filters
9. **Inspect tokens** and user data
10. **Final breakpoint** in `dashboard()` method

## 📝 Useful Debug Console Commands

While debugging, try these in the Debug Console:

```java
// Check current authentication
SecurityContextHolder.getContext().getAuthentication()

// Check OAuth2 user attributes  
((OAuth2User) principal).getAttributes()

// Check authorities/roles
principal.getAuthorities()

// Check session
request.getSession().getAttribute("SPRING_SECURITY_CONTEXT")
```

---

**Happy Debugging! 🐛→✅**

Remember: OAuth2 flow involves multiple redirects, so you'll see breakpoints hit in different filters as the flow progresses. 