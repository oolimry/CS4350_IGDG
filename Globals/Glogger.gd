class_name Glogger
extends Resource

enum level {
	ERROR,
	WARNING,
	INFO,
	VERBOSE,
}

## this is for general debugging
## use this over printt cause then we know where the debugging statement is from
static func debug(message  = ""):
	var stack = get_stack()
	printt(message, stack[1]["source"], stack[1]["line"])

## this is when you need to know the time in which something happens
## useful for debugging lag spikes or which part takes forever to load
static func time(message = ""):
	var stack = get_stack()
	printt(Time.get_ticks_msec(), message, stack[1]["source"], stack[1]["line"], "GTIME")

## i rarely use this
static func log(_level : level, message: String):
	if _level == level.ERROR:
		triggerError(message)
		assert(false)
		
	if _level == level.WARNING:
		triggerWarning(message)
		
	if _level == level.INFO:
		triggerInfo(message)
	
	if _level == level.VERBOSE:
		triggerVerbose(message)
		
static func triggerError(message):
	print("ERROR: " + message)
	assert(false)
	
static func triggerWarning(message):
	print("WARNING: " + message)
		
static func triggerInfo(message):
	print("INFO: " + message)

static func triggerVerbose(message):
	print("VINFO: " + message)
	pass

static func ass(condition, message):
	if not condition:
		Glogger.log(level.ERROR, message)
