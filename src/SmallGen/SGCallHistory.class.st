Class {
	#name : #SGCallHistory,
	#superclass : #Object,
	#instVars : [
		'records',
		'theClass',
		'theValue'
	],
	#category : #SmallGen
}

{ #category : #'instance creation' }
SGCallHistory class >> for: anObject [
	^ self new for: anObject; yourself 
]

{ #category : #accessing }
SGCallHistory >> append: aRecord [
	self records add: aRecord
]

{ #category : #accessing }
SGCallHistory >> copy [
	^ self class new records:
		(records collect: [ :r | r copy ]);
		yourself
]

{ #category : #'instance creation' }
SGCallHistory >> for: anObject [
	self initialize.
	self theClass: anObject class.
	self theValue: anObject
]

{ #category : #accessing }
SGCallHistory >> records [
	^ records ifNil: [ records := OrderedCollection new ]
]

{ #category : #accessing }
SGCallHistory >> records: recs [
	records := recs
]

{ #category : #accessing }
SGCallHistory >> theClass [
	^ theClass
]

{ #category : #accessing }
SGCallHistory >> theClass: anObject [
	theClass := anObject
]

{ #category : #accessing }
SGCallHistory >> theValue [
	^ theValue
]

{ #category : #accessing }
SGCallHistory >> theValue: anObject [
	theValue := anObject
]
