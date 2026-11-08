class_name GlobalGameState
extends Node

enum PhaseOfGame {
	INTRO_CUTSCENE,
	GAMEPLAY,
	CREDITS,
}

static var phaseOfGame : PhaseOfGame = PhaseOfGame.INTRO_CUTSCENE

static func isGameplay() -> bool:
	return phaseOfGame == PhaseOfGame.GAMEPLAY
