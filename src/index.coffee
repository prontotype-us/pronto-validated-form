React = require 'react'
helpers = require './helpers'
validation = require './validation'

ValidatedFormMixin =
    validate: ->
        helpers.compactObj helpers.mapObjKey @fields, (field_name) =>
            @refs[field_name].validate()

    values: ->
        helpers.mapObjKey @fields, (field_name) =>
            @refs[field_name].value()

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

    renderField: (field_name) ->
        field = @fields[field_name]

        <ValidatedField {...field}
            ref=field_name key=field_name
            name=field_name
            value=@state.values?[field_name]
            error=@state.errors?[field_name]
            onChange=@onChange(field_name)
        />

ValidatedField = React.createClass
    getDefaultProps: ->
        type: 'text'

    value: ->
        return @props.value

    validate: ->
        if @props.optional
            return null

        validator = @props.validator || validation[@props.type] || validation.exists
        if !validator(@props.value)
            return @props.error_message || "Nothing in #{@props.name}"

        return null

    changeValue: (e) ->
        value = e.target?.value || e
        @props.onChange(value)

    render: ->

        field_class = 'field'
        if @props.error
            field_class += ' has-error'

        <div className=field_class>
            {switch @props.type
                when 'toggle'
                    <Toggle options=@props.options onChange=@changeValue selected=@props.value />
                when 'select'
                    <select value=@props.value onChange=@changeValue>
                        <option>Select one</option>
                        {@props.options.map (o) ->
                            <option value={o.value || o}>{o.display || o}</option>
                        }
                    </select>
                else         
                    <input key=@props.name
                        name=@props.name
                        type=@props.type
                        placeholder={@props.placeholder || @props.name}
                        value=@props.value
                        onChange=@changeValue
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