import { createI18n } from 'vue-i18n'
import languages from '../../../locales/languages.json'

const localeFiles = import.meta.glob('../../../locales/!(languages).json', { eager: true })

const messages = {}
const availableLocales = []

for (const path in localeFiles) {
  const key = path.match(/\/([^/]+)\.json$/)[1]
  if (languages[key]) {
    messages[key] = localeFiles[path].default
    availableLocales.push({ key, label: languages[key].label })
  }
}

// Only keep a previously saved locale if it is still available; otherwise
// fall back to English (the sole supported UI language).
const rawSavedLocale = localStorage.getItem('locale')
const savedLocale = messages[rawSavedLocale] ? rawSavedLocale : 'en'

const i18n = createI18n({
  legacy: false,
  locale: savedLocale,
  fallbackLocale: 'en',
  messages
})

export { availableLocales }
export default i18n
