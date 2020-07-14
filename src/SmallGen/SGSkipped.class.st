Class {
	#name : #SGSkipped,
	#superclass : #SGState,
	#category : #'SmallGen-Model'
}

{ #category : #accessing }
SGSkipped class >> tag [ 	^ 'Skipped'
]

{ #category : #'instance creation' }
SGSkipped class >> with: aValue [
	^ self new
		theValue: aValue;
		yourself
]

{ #category : #converting }
SGSkipped >> asString [
	^ '' join: {self class tag.self theValue class name}
]
