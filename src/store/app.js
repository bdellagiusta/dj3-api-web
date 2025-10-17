import { defineStore, acceptHMRUpdate } from 'pinia'
import logo from '@/assets/logo.png'
import en from 'element-plus/es/locale/lang/en'
import es from 'element-plus/es/locale/lang/es'
import { admin, app, server } from '@/api/config'

const langs = {
  'en': { name: 'English', value: en, sideBarWidth: '230px' },
  'es': { name: 'Español', value: es, sideBarWidth: '280px' },
}
const defaultLang = localStorage.getItem('lang') || navigator.language || 'zh-CN'
export const useAppStore = defineStore({
  id: 'App',
  state: () => ({
    setting: {
      title: 'Rustdesk API Admin',
      hello: '',
      sideIsCollapse: false,
      logo,
      langs: langs,
      lang: defaultLang,
      locale: langs[defaultLang] ? langs[defaultLang] : langs['en'],
      appConfig: {
        web_client: 1,
      },
      rustdeskConfig: {
        'id_server': '',
        'key': '',
        'relay_server': '',
        'api_server': '',
      },
    },
  }),

  actions: {
    sideCollapse () {
      this.setting.sideIsCollapse = !this.setting.sideIsCollapse
    },
    setLang (lang) {
      console.log('setLang', lang)
      this.setting.lang = lang
      this.setting.locale = langs[lang]
      localStorage.setItem('lang', lang)
    },
    changeLang (v) {
      this.setLang(v)
    },
    loadConfig () {
      this.getAppConfig()
      this.getAdminConfig()
      this.loadRustdeskConfig()
    },
    getAppConfig () {
      console.log('getAppConfig')
      return app().then(res => {
        this.setting.appConfig = res.data
      })
    },
    getAdminConfig () {
      console.log('getAdminConfig')
      return admin().then(res => {
        this.replaceAdminTitle(res.data.title)
        this.setting.hello = res.data.hello
      })
    },
    replaceAdminTitle (newTitle) {
      document.title = document.title.replace(`- ${this.setting.title}`, `- ${newTitle}`)
      this.setting.title = newTitle
    },
    async loadRustdeskConfig () {
      console.log('loadRustdeskConfig')
      const res = await server().catch(_ => false)
      if (res) {
        this.setting.rustdeskConfig = res.data
        const prefix = 'wc-'
        localStorage.setItem(`${prefix}custom-rendezvous-server`, res.data.id_server)
        localStorage.setItem(`${prefix}key`, res.data.key)
        localStorage.setItem(`${prefix}api-server`, res.data.api_server)
      }

    },
  },
})

if (import.meta.hot) {
  import.meta.hot.accept(acceptHMRUpdate(useAppStore, import.meta.hot))
}
