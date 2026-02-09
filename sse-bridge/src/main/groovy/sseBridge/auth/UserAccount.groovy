package sseBridge.auth

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table
import com.fasterxml.jackson.databind.JsonNode

@Table("user_account")
class UserAccount {

    @Id
    Long id
    String apiKey
    JsonNode access

    Boolean hasAccess(String resource) {
        if (access == null) {
            return false
        }

        def accessNode = access.get(resource)
        return accessNode != null && accessNode.asBoolean(false)
    }
}

