_ = require 'underscore'
React = require 'react'
classSet = require 'react-classset'
helpers = require './helpers'
validation = require './validation'

ValidatedFormMixin =
    resetState: ->
        @setState @getInitialState()

    validate: ->
        helpers.compactObj helpers.mapObjKey @props.fields or @fields, (field_name) =>
            @refs[field_name]?.validate()

    values: ->
        helpers.mapObjKey @props.fields or @fields, (field_name) =>
            @refs[field_name]?.value()

    # Validate and maybe even submit form
    trySubmit: (e) ->
        e.preventDefault()

        if !@state.loading
            @setState {errors: {}}

            errors = @validate()

            if Object.keys(errors).length > 0
                @setState {errors: errors}

            else
                values = @values()
                @onSubmit(values)

    onChange: (key) -> (value) =>
        values = @state.values || {}
        values[key] = value
        @setState {values}, =>
            @onChanged?(key, value)

    clear: ->
        @setState {values: {}, errors: {}}

    renderFields: ->
        fields = @props.fields or @fields
        <div>
            {Object.keys(fields).map (field_name) =>
                @renderField field_name
            }
        </div>

    renderField: (field_name) ->
        fields = @props.fields or @fields
        field = fields[field_name] 

        <ValidatedField {...field}
            ref=field_name
            key=field_name
            name=field_name
            value=@state.values?[field_name]
            error=@state.errors?[field_name]
            onChange=@onChange(field_name)
            values=@state.values
        />

ValidatedField = React.createClass
    getDefaultProps: ->
        type: 'text'

    value: ->
        return @props.value

    validate: ->
        # Don't bother validating optional fields
        if _.isFunction(@props.optional)
            if @props.optional(@props.values)
                return null

        else if @props.optional
            return null

        if _.isFunction(@props.hidden)
            if @props.hidden(@props.values)
                return null

        else if @props.hidden
            return null

        validator = @props.validator || validation[@props.type] || validation.exists
        if !validator(@props.value)
            return @props.error_message || "Nothing in #{@props.name}"

        return null

    changeValue: (e) ->
        value = if e.target? then e.target.value else e
        @props.onChange(value)

    focus: ->
        @refs.field.focus()

    isOptional: ->

        if _.isFunction(@props.optional)
            return @props.optional(@props.values)

        else if @props.optional
            return true

        else
            false

    render: ->

        form_group_class_set =
            'form-group': true
            'has-error': @props.error
            'required': !@isOptional()
        form_group_class_set["#{@props.name}"] = true
        form_group_class_set["#{@props.className}"] = true
        form_group_class = classSet form_group_class_set

        _value = @props.value

        if @props.type == 'phone'
            dashless = _value.replace(/-/g,'')
            if dashless.length == 4
                value = dashless[0..2] + '-' + dashless[3..]
            else if dashless.length == 7
                value = dashless[0..2] + '-' + dashless[3..5] + '-' + dashless[6..]
            else
                value = _value
        else
            value = _value

        <div className=form_group_class>
            {if @props.type != 'hidden'
                <label htmlFor=@props.name>
                    {if @props.icon
                        <i className="fa fa-#{@props.icon}" />
                    }
                    {@props.label || helpers.humanize(@props.name)}
                </label>
            }

            {switch @props.type
                when 'toggle'
                    <Toggle options=@props.options onChange=@changeValue selected=@props.value />
                when 'select'
                    <select value=@props.value onChange=@changeValue>
                        <option>{@props.placeholder || 'Select one'}</option>
                        {@props.options.map (o) ->
                            <option key={o.value || o} value={o.value || o}>{o.display || o}</option>
                        }
                    </select>
                when 'textarea'
                    <textarea key=@props.name
                        ref='field'
                        name=@props.name
                        type=@props.type
                        placeholder={@props.placeholder || helpers.humanize(@props.name)}
                        value=@props.value
                        onChange=@changeValue
                        autoComplete=@props.autoComplete
                        autoCorrect=@props.autoCorrect
                    />
                else
                    <input key=@props.name
                        ref='field'
                        name=@props.name
                        type=@props.type
                        placeholder={@props.placeholder || helpers.humanize(@props.name)}
                        value=value
                        onChange=@changeValue
                        autoComplete=@props.autoComplete
                        autoCorrect=@props.autoCorrect
                    />
            }

            {if @props.error
                <span className='error'>{@props.error}</span>
            }
        </div>

Toggle = React.createClass
    getInitialState: ->
        selected: @props.selected || ''

    select: (key) -> =>
        @value = key
        @setState selected: key
        @props.onChange?(key)

    selected: (key) ->
        if @state.selected == key
            'selected'
        else
            ''

    render: ->
        <div className='toggle'>
            {@props.options.map @renderOption}
        </div>

    renderOption: (option, i) ->
        <a key=i onClick=@select(option) className=@selected(option)>{option}</a>

module.exports = {
    ValidatedField
    ValidatedFormMixin
}

