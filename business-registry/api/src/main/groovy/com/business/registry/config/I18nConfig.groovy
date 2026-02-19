package com.business.registry.config

import groovy.transform.CompileStatic
import org.springframework.context.MessageSource
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.support.ReloadableResourceBundleMessageSource
import org.springframework.web.servlet.LocaleResolver
import org.springframework.web.servlet.config.annotation.InterceptorRegistry
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer
import org.springframework.web.servlet.i18n.AcceptHeaderLocaleResolver
import org.springframework.web.servlet.i18n.LocaleChangeInterceptor

import java.nio.charset.StandardCharsets

@Configuration
@CompileStatic
class I18nConfig implements WebMvcConfigurer {

    @Bean
    MessageSource messageSource() {
        ReloadableResourceBundleMessageSource messageSource = new ReloadableResourceBundleMessageSource()
        messageSource.setBasename("classpath:i18n/messages")
        messageSource.setDefaultEncoding(StandardCharsets.UTF_8.name())
        messageSource.setDefaultLocale(Locale.ENGLISH)
        messageSource.setCacheSeconds(3600) // Cache for 1 hour
        messageSource.setFallbackToSystemLocale(false)
        return messageSource
    }

    @Bean
    LocaleResolver localeResolver() {
        AcceptHeaderLocaleResolver localeResolver = new AcceptHeaderLocaleResolver()
        localeResolver.setDefaultLocale(Locale.ENGLISH)
        localeResolver.setSupportedLocales(Arrays.asList(
            Locale.ENGLISH,
            Locale.of("el"), // Greek
        ))
        return localeResolver
    }

    @Bean
    LocaleChangeInterceptor localeChangeInterceptor() {
        LocaleChangeInterceptor interceptor = new LocaleChangeInterceptor()
        interceptor.setParamName("lang")
        return interceptor
    }

    @Override
    void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(localeChangeInterceptor())
    }
}



