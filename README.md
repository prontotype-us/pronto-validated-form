# validated-form

Helpers for creating a form with validated fields.

## ValidatedForm

###  Properties

* `fields` An object of field names and options `{name: options, ...}`. See field options for more information
* `values` An object of field values `{name: value, ...}`
* `onSubmit(values)` A function to be called when the form is submitted (only if fields are valid)

### Example

```coffee
<ValidatedForm ref='form' fields={
	street: {name: 'street'}
	city: {name: 'city'}
	state: {name: 'state', placeholder: 'e.g. "NY" or "MA"'}
	county: {name: 'county', optional: true}
} onSubmit={(street) -> alert('this street is in ' + street.city) } />
```

## ValidatedField

### Properties

* `name` Name of this field
* `type` One of "text", "number", "email", or "toggle", default is "text"
* `placeholder` A placeholder, default is the un-slugified field name
* `error_message` Message to show if field is invalid
* `hidden` A boolean or function to determine if this field is hidden
* `optional` A boolean or function to determine if this field is optional

## ValidatedFormMixin

The `ValidatedFormMixin` provides methods for rendering fields, keeping track of fields state, and checking that fields are valid.

### Class attributes

* `getInitialState() -> {values}` *required*
    * A component that uses this mixin *must* define a `getInitialState` that returns at least an empty `values: {}`, because a React component does not have state by default
    * You can also use this to pre-fill values of fields, with e.g. `values: {email: 'test@gmail.net'}`
* `getDefaultProps() -> {fields, onSubmit}`
	* Define fields and other props here, or pass them in as props instead
* `onSubmit(values)`
	* A function to be called when the form is submitted (only if fields are valid)
	* Can be defined directly on your class instead of as a property

### Properties 

* `fields` An object of field names and options in the shape `{name: options, ...}`. See field options for more information
* `onSubmit(values)` A function to be called when the form is submitted (only if fields are valid)

### State

* `values` An object of values by field name

### Methods from mixin

* `renderField(name)` Render an individual field with the options in `fields[name]`
* `trySubmit()` A method that looks through fields
* `clear()` Sets all field values to null

### Example

```coffee
{ValidatedFormMixin} = require 'validated-form'

FormTest = React.createClass
    mixins: [ValidatedFormMixin]

    getInitialState: ->
        values:
            name: 'test'

	getDefaultProps: ->
		fields:
			name: {type: 'text'}
			age: {type: 'number'}
			email: {type: 'email'}

    onSubmit: (values) ->
        @setState {loading: true}
        submitFormAnd =>
            @clear()
            @setState {loading: false}

    render: ->
        <div>
            <form onSubmit=@trySubmit>
                {@renderField 'name'}
                {@renderField 'age'}
                {@renderField 'email'}
                <button>{if @state.loading then "Loading..." else "Submit"}</button>
            </form>
        </div>
```

