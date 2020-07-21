Class {
	#name : #SGDefaultStrategy,
	#superclass : #SGAbstractStrategy,
	#category : #'SmallGen-Strategy'
}

{ #category : #decoration }
SGDefaultStrategy >> prepare [
	self halt.
	"observations := SGHistoryFilter new minimizerFor: observations.
	observations := SGRecordFilter new minimizerFor: observations."
	^ observations
]
