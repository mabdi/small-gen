Class {
	#name : #SGAbstractStrategy,
	#superclass : #Object,
	#instVars : [
		'observations',
		'classesToGenerate',
		'classesToObserve'
	],
	#category : #'SmallGen-Strategy'
}

{ #category : #accessing }
SGAbstractStrategy >> classesToGenerate [
	^ classesToGenerate
]

{ #category : #accessing }
SGAbstractStrategy >> classesToGenerate: anObject [
	classesToGenerate := anObject
]

{ #category : #accessing }
SGAbstractStrategy >> classesToObserve [
	^ classesToObserve
]

{ #category : #accessing }
SGAbstractStrategy >> classesToObserve: anObject [
	classesToObserve := anObject
]

{ #category : #accessing }
SGAbstractStrategy >> observations [
	^ observations
]

{ #category : #accessing }
SGAbstractStrategy >> observations: anObject [
	observations := anObject
]

{ #category : #decoration }
SGAbstractStrategy >> prepare [ 
	^self subclassResponsibility 
]
