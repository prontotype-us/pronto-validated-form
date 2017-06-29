exists = (value) ->
    if !value?
        return false
    if typeof value == 'string'
        return has_length(value)
    else
        return true

has_length = (value) ->
    value?.length > 0

valid_phone = (value) ->
    phone_regexp = RegExp '^\\(?[0-9]{3}-?[0-9]{3}-?[0-9]{4}$', 'i'
    return value?.match(phone_regexp)

valid_email = (value) ->
    email_regexp = RegExp '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$', 'i'
    return value?.match(email_regexp)

valid_checkbox = (value) ->
    return true

module.exports = {
    exists
    has_length
    valid_phone
    valid_email
    valid_checkbox
}
