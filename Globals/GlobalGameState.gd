class_name GlobalGameState
extends Node

enum PhaseOfGame {
	INTRO_CUTSCENE,
	GAMEPLAY,
}

static var phaseOfGame : PhaseOfGame = PhaseOfGame.INTRO_CUTSCENE
