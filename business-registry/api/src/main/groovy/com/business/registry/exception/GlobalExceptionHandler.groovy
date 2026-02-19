package com.business.registry.exception

import com.business.registry.dto.util.ErrorResponseDto
import com.business.registry.service.MessageService
import groovy.transform.CompileStatic
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.http.converter.HttpMessageNotReadableException
import org.springframework.validation.FieldError
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.annotation.ControllerAdvice
import org.springframework.web.bind.annotation.ExceptionHandler

@ControllerAdvice
@CompileStatic
class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class)

    private final MessageService messageService

    GlobalExceptionHandler(MessageService messageService) {
        this.messageService = messageService
    }

    @ExceptionHandler(MethodArgumentNotValidException)
    ResponseEntity<ErrorResponseDto> handleValidationExceptions(MethodArgumentNotValidException ex) {
        List<String> errors = ex.bindingResult.allErrors.collect { error ->
            if (error instanceof FieldError) {
                FieldError fieldError = (FieldError) error
                String message = fieldError.defaultMessage
                if (message && message.contains('.')) {
                    return messageService.getMessage(message, message)
                }
                return message
            }
            return error.defaultMessage
        }

        String errorMessage = errors.join(', ')
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponseDto(errorMessage, HttpStatus.BAD_REQUEST.value()))
    }

    @ExceptionHandler(IllegalStateException)
    ResponseEntity<ErrorResponseDto> handleIllegalStateException(IllegalStateException ex) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponseDto(ex.getMessage(), HttpStatus.BAD_REQUEST.value()))
    }

    @ExceptionHandler(IllegalAccessException)
    ResponseEntity<ErrorResponseDto> handleIllegalAccessException(IllegalAccessException ex) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(new ErrorResponseDto(ex.getMessage(), HttpStatus.FORBIDDEN.value()))
    }

    @ExceptionHandler(IllegalArgumentException)
    ResponseEntity<ErrorResponseDto> handleIllegalArgumentException(IllegalArgumentException ex) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponseDto(ex.getMessage(), HttpStatus.BAD_REQUEST.value()))
    }

    @ExceptionHandler(BadRequestException)
    ResponseEntity<ErrorResponseDto> handleBadRequestException(BadRequestException ex) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponseDto(ex.getMessage(), HttpStatus.BAD_REQUEST.value()))
    }

    @ExceptionHandler(NotFoundException)
    ResponseEntity<ErrorResponseDto> handleNotFoundException(NotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ErrorResponseDto(ex.getMessage(), HttpStatus.NOT_FOUND.value()))
    }

    @ExceptionHandler(UnauthorizedException)
    ResponseEntity<ErrorResponseDto> handleUnauthorizedException(UnauthorizedException ex) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(new ErrorResponseDto(ex.getMessage(), HttpStatus.UNAUTHORIZED.value()))
    }

    @ExceptionHandler(HttpMessageNotReadableException)
    ResponseEntity<ErrorResponseDto> handleHttpMessageNotReadableException() {
        String message = messageService.getMessage("Μη.έγκυρο.σώμα.αιτήματος.")
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponseDto(message, HttpStatus.BAD_REQUEST.value()))
    }

    @ExceptionHandler(Exception)
    ResponseEntity<ErrorResponseDto> handleGenericException(Exception ex) {
        log.error("An unexpected error occurred: ${ex.message}", ex)
        String message = messageService.getMessage("Σφάλμα.συστήματος.Επικοινωνήστε.με.τον.διαχειριστή.")
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorResponseDto(message, HttpStatus.INTERNAL_SERVER_ERROR.value()))
    }
}

