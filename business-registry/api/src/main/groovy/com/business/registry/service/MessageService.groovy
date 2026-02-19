package com.business.registry.service

import groovy.transform.CompileStatic
import org.springframework.context.MessageSource
import org.springframework.context.i18n.LocaleContextHolder
import org.springframework.stereotype.Service

@Service
@CompileStatic
class MessageService {

    private final MessageSource messageSource

    MessageService(MessageSource messageSource) {
        this.messageSource = messageSource
    }

    /**
     * Get a message by key using the current locale from LocaleContextHolder
     * @param key the message key
     * @return the translated message
     */
    String getMessage(String key) {
        return messageSource.getMessage(key, null, LocaleContextHolder.getLocale())
    }

    /**
     * Get a message by key with arguments using the current locale
     * @param key the message key
     * @param args the arguments to be used in the message
     * @return the translated message with arguments
     */
    String getMessage(String key, Object[] args) {
        return messageSource.getMessage(key, args, LocaleContextHolder.getLocale())
    }

    /**
     * Get a message by key with a specific locale
     * @param key the message key
     * @param locale the locale to use
     * @return the translated message
     */
    String getMessage(String key, Locale locale) {
        return messageSource.getMessage(key, null, locale)
    }

    /**
     * Get a message by key with arguments and a specific locale
     * @param key the message key
     * @param args the arguments to be used in the message
     * @param locale the locale to use
     * @return the translated message with arguments
     */
    String getMessage(String key, Object[] args, Locale locale) {
        return messageSource.getMessage(key, args, locale)
    }

    /**
     * Get a message by key with a default message if the key is not found
     * @param key the message key
     * @param defaultMessage the default message if key not found
     * @return the translated message or default message
     */
    String getMessage(String key, String defaultMessage) {
        return messageSource.getMessage(key, null, defaultMessage, LocaleContextHolder.getLocale())
    }
}


