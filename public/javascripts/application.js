$(document).ready(function() {

	$("form.delete").submit(function(event) {
		event.preventDefault();
		event.stopPropagation()

		var ok = confirm("Are youy sure? This cannot be undone.")
		
		if (ok) {
			this.submit()
		}
	})
})
