<template>
  <div class="login-container">
    <!-- Subtle background -->
    <div class="bg-gradient"></div>
    <div class="bg-pattern"></div>

    <div class="login-card">
      <!-- Logo Section -->
      <div class="logo-section">
        <div class="logo-wrapper">
          <img src="@/assets/logo.png" alt="logo" class="login-logo"/>
        </div>
        <h1 class="title">Dj3 Networks</h1>
        <p class="subtitle">Digital Signage Services & Solutions</p>
      </div>

      <!-- Login Form -->
      <el-form v-if="!disablePwd" label-position="top" class="login-form">
        <el-form-item :label="T('Username')" class="form-item">
          <el-input 
            v-model="form.username" 
            type="username" 
            class="custom-input" 
            :placeholder="T('Enter your username')"
            size="large">
            <template #prefix>
              <i class="el-icon-user input-icon"></i>
            </template>
          </el-input>
        </el-form-item>

        <el-form-item :label="T('Password')" class="form-item">
          <el-input 
            v-model="form.password" 
            type="password" 
            @keyup.enter.native="login" 
            show-password
            class="custom-input" 
            :placeholder="T('Enter your password')"
            size="large">
            <template #prefix>
              <i class="el-icon-lock input-icon"></i>
            </template>
          </el-input>
        </el-form-item>

        <el-form-item :label="T('Captcha')" v-if="captchaCode" class="form-item">
          <el-input 
            v-model="form.captcha" 
            @keyup.enter.native="login" 
            class="custom-input captcha-input"
            size="large">
            <template #append>
              <img :src="captchaCode.b64" @click="loadCaptcha" class="captcha-image" alt="captcha"/>
            </template>
          </el-input>
        </el-form-item>

        <div class="button-group">
          <el-button @click="login" type="primary" class="primary-button" size="large">
            {{ T('Login') }}
          </el-button>
          <el-button v-if="allowRegister" @click="register" class="secondary-button" size="large">
            {{ T('Register') }}
          </el-button>
        </div>
      </el-form>

      <!-- Divider -->
      <div class="divider" v-if="options.length > 0 && !disablePwd">
        <span>{{ T('or continue with') }}</span>
      </div>

      <!-- OIDC Options -->
      <div class="oidc-section" v-if="options.length > 0">
        <el-button 
          v-for="(option, index) in options" 
          :key="index"
          @click="handleOIDCLogin(option.name)" 
          class="oidc-button"
          size="large">
          <img :src="getProviderImage(option.name)" alt="provider" class="provider-icon"/>
          <span>{{ T(option.name) }}</span>
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
  import { reactive, onMounted, ref } from 'vue'
  import { useUserStore } from '@/store/user'
  import { ElMessage } from 'element-plus'
  import { T } from '@/utils/i18n'
  import { useRoute, useRouter } from 'vue-router'
  import { loginOptions, captcha } from '@/api/login'
  import { getCode, removeCode } from '@/utils/auth'

  const oauthInfo = ref({})
  const userStore = useUserStore()
  const route = useRoute()
  const router = useRouter()
  const options = reactive([])

  let platform = window.navigator.platform
  if (navigator.platform.indexOf('Mac') === 0) {
    platform = 'mac'
  } else if (navigator.platform.indexOf('Win') === 0) {
    platform = 'windows'
  } else if (navigator.platform.indexOf('Linux armv') === 0) {
    platform = 'android'
  } else if (navigator.platform.indexOf('Linux') === 0) {
    platform = 'linux'
  }
  const userAgent = navigator.userAgent
  let browser = 'Unknown Browser'
  if (/chrome|crios/i.test(userAgent)) browser = 'Chrome'
  else if (/firefox|fxios/i.test(userAgent)) browser = 'Firefox'
  else if (/safari/i.test(userAgent) && !/chrome/i.test(userAgent)) browser = 'Safari'
  else if (/edg/i.test(userAgent)) browser = 'Edge'

  const form = reactive({
    username: '',
    password: '',
    platform: platform,
    captcha: '',
    captcha_id: ''
  })

  const captchaCode = ref('')
  const redirect = route.query?.redirect
  const login = async () => {
    const res = await userStore.login(form).catch(e => e)
    if (!res.code) {
      ElMessage.success(T('LoginSuccess'))
      router.push({ path: redirect || '/', replace: true })
      return
    }
    if (res.code === 110) {
      loadCaptcha()
    }
  }

  const loadCaptcha = async () => {
    const captchaRes = await captcha().catch(_ => false)
    console.log(captchaRes)
    captchaCode.value = captchaRes.data.captcha
    form.captcha_id = captchaRes.data.captcha.id
  }

  const handleOIDCLogin = (provider) => {
    userStore.oidc(provider, platform, browser)
  }

  import googleImage from '@/assets/google.png'
  import githubImage from '@/assets/github.png'
  import oidcImage from '@/assets/oidc.png'
  import webauthImage from '@/assets/webauth.png'
  import defaultImage from '@/assets/oidc.png'

  const providerImageMap = {
    google: googleImage,
    github: githubImage,
    oidc: oidcImage,
    default: defaultImage,
  }

  const getProviderImage = (provider) => {
    return providerImageMap[provider.toLowerCase()] || providerImageMap.default
  }

  const allowRegister = ref(false)
  const disablePwd = ref(false)
  const loadLoginOptions = async () => {
    try {
      const res = await loginOptions().catch(_ => false)
      if (!res || !res.data) return console.error('No valid response received')
      res.data.ops.map(option => (options.push({ name: option })))
      if (res.data.auto_oidc) {
        handleOIDCLogin(res.data.ops[0])
      }
      disablePwd.value = res.data.disable_pwd
      allowRegister.value = res.data.register
      if (res.data.need_captcha) {
        loadCaptcha()
      }
    } catch (error) {
      console.error('Error loading login options:', error.message)
    }
  }

  onMounted(async () => {
    const code = getCode()
    if (code) {
      const res = await userStore.query(code)
      if (res) {
        removeCode()
        ElMessage.success(T('LoginSuccess'))
        router.push({ path: redirect || '/', replace: true })
      }
    } else {
      loadLoginOptions() 
    }
  })

  const register = () => {
    router.push('/register')
  }
</script>

<style scoped lang="scss">
// Minimal, professional animations
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(15px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

// Container
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  width: 100vw;
  max-width: 100%;
  padding: 30px;
  position: relative;
  overflow-x: hidden;
  overflow-y: auto;
  background: #1a242f;
  box-sizing: border-box;
}

.bg-gradient {
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, #1e2732 0%, #2d3a4b 50%, #1a242f 100%);
}

.bg-pattern {
  position: absolute;
  inset: 0;
  background-image: 
    linear-gradient(rgba(233, 117, 22, 0.03) 1px, transparent 1px),
    linear-gradient(90deg, rgba(233, 117, 22, 0.03) 1px, transparent 1px);
  background-size: 40px 40px;
  opacity: 0.4;
}

// Card
.login-card {
  width: 100%;
  max-width: 460px;
  background: rgba(40, 51, 66, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 16px;
  padding: 48px 44px;
  box-shadow: 
    0 10px 40px rgba(0, 0, 0, 0.3),
    0 0 0 1px rgba(255, 255, 255, 0.05);
  position: relative;
  z-index: 1;
  animation: fadeIn 0.5s ease-out;
  

}

// Logo Section
.logo-section {
  text-align: center;
  margin-bottom: 40px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  padding-bottom: 30px;
}

.logo-wrapper {
  display: inline-block;
  margin-bottom: 20px;
}

.login-logo {
  width: 80px;
  height: 80px;
  display: block;
  filter: drop-shadow(0 4px 12px rgba(233, 117, 22, 0.2));
}

.title { 
  font-family: 'Century Gothic', 'Segoe UI', sans-serif; 
  font-size: 2.8rem;
  font-weight: 600;
  color: #ffffff;
  margin: 0 0 13px 0;
  letter-spacing: -0.2px;
  line-height: 1.2;
}

.subtitle {
  font-family: 'Century Gothic', 'Segoe UI', sans-serif; 
  font-size: 0.9rem;
  font-weight: 600;
  color: #e97516;
  margin: 0;
  letter-spacing: 2px;
  text-transform: uppercase;
}

// Form
.login-form {
  margin-bottom: 28px;
}

.form-item {
  margin-bottom: 22px;
  
  ::v-deep(.el-form-item__label) {
    color: #d1d5db;
    font-weight: 600;
    font-size: 13px;
    margin-bottom: 8px;
    letter-spacing: 0.2px;
  }
}

.custom-input {
  ::v-deep(.el-input__wrapper) {
    border: 1.5px solid rgba(255, 255, 255, 0.12);
    background: rgba(255, 255, 255, 0.05);
    border-radius: 10px;
    padding: 8px 25px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    transition: all 0.2s ease;
    
    &:hover {
      border-color: rgba(255, 255, 255, 0.2);
      background: rgba(255, 255, 255, 0.07);
    }
    
    &.is-focus {
      border-color: #e97516;
      background: rgba(255, 255, 255, 0.08);
      box-shadow: 0 0 0 3px rgba(233, 117, 22, 0.15);
    }
  }

  ::v-deep(input) {
    color: #ffffff;
    font-size: 15px;
    font-weight: 400;
    
    &::placeholder {
      color: rgba(255, 255, 255, 0.4);
    }
  }
  
  .input-icon {
    color: #e97516;
    font-size: 15px;
    margin-right: 2px;
  }
}

.captcha-input {
  ::v-deep(.el-input-group__append) {
    border-radius: 0 10px 10px 0;
    padding: 0;
    overflow: hidden;
    background: rgba(255, 255, 255, 0.05);
    border: 1.5px solid rgba(255, 255, 255, 0.12);
    border-left: none;
  }
  
  .captcha-image {
    cursor: pointer;
    width: 120px;
    height: 100%;
    object-fit: cover;
    transition: opacity 0.2s ease;
    
    &:hover {
      opacity: 0.8;
    }
  }
}

// Buttons
.button-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-top: 28px;
}

.primary-button {
  width: 100%;
  height: 52px;
  background: linear-gradient(180deg, #e97516 0%, #d96b14 100%);
  border: none;
  border-radius: 10px;
  font-size: 15px;
  font-weight: 600;
  color: #ffffff;
  letter-spacing: 0.3px;
  transition: all 0.2s ease;
  
  &:hover {
    background: linear-gradient(180deg, #f57f1d 0%, #e97516 100%);
    box-shadow: 0 8px 20px rgba(233, 117, 22, 0.4);
    transform: translateY(-1px);
  }
  
  &:active {
    transform: translateY(0);
    box-shadow: 0 4px 12px rgba(233, 117, 22, 0.3);
  }
}

.secondary-button {
  width: 100%;
  height: 52px;
  background: transparent;
  border: 1.5px solid rgba(233, 117, 22, 0.5);
  border-radius: 10px;
  font-size: 15px;
  font-weight: 600;
  color: #e97516;
  letter-spacing: 0.3px;
  transition: all 0.2s ease;
  
  &:hover {
    background: rgba(233, 117, 22, 0.1);
    border-color: #e97516;
    transform: translateY(-1px);
  }
  
  &:active {
    transform: translateY(0);
  }
}

// Divider
.divider {
  display: flex;
  align-items: center;
  margin: 32px 0 28px 0;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.5);
  text-transform: uppercase;
  letter-spacing: 1px;
  font-weight: 500;

  &::before,
  &::after {
    content: '';
    flex: 1;
    height: 1px;
    background: linear-gradient(to right, transparent, rgba(255, 255, 255, 0.15), transparent);
  }

  span {
    padding: 0 16px;
  }
}

// OIDC
.oidc-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.oidc-button {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  width: 100%;
  height: 52px;
  background: rgba(255, 255, 255, 0.95);
  border: 1.5px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  color: #1a202c;
  font-size: 15px;
  font-weight: 600;
  letter-spacing: 0.2px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  transition: all 0.2s ease;
  
  &:hover {
    background: #ffffff;
    box-shadow: 0 6px 16px rgba(0, 0, 0, 0.2);
    transform: translateY(-1px);
  }
  
  &:active {
    transform: translateY(0);
  }
}

.provider-icon {
  width: 20px;
  height: 20px;
}

// Responsive
@media (max-width: 768px) {
  .login-container {
    padding: 20px;
  }
  
  .login-card {
    padding: 40px 32px;
  }
  
  .logo-section {
    margin-bottom: 36px;
    padding-bottom: 28px;
  }
  
  .login-logo {
    width: 70px;
    height: 70px;
  }
  
  .title {
    font-size: 2rem;
  }
  
  .subtitle {
    font-size: 0.7rem;
  }
  
  .primary-button,
  .secondary-button,
  .oidc-button {
    height: 50px;
  }
}

@media (max-width: 480px) {
  .login-card {
    padding: 36px 28px;
  }
  
  .logo-section {
    margin-bottom: 32px;
  }
  
  .title {
    font-size: 2rem;
  }
}
</style>