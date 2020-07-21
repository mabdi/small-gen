Class {
	#name : #BaselineOfSmallGen,
	#superclass : #BaselineOf,
	#category : #BaselineOfSmallGen
}

{ #category : #baselines }
BaselineOfSmallGen >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec
				baseline: 'Mocketry'
				with: [ spec repository: 'github://dionisiydk/Mocketry' ].
			spec package: 'SmallGen' with: [ spec requires: #('Mocketry') ].
			"spec
				package: 'SmallAmp-Tests'
				with: [ spec requires: #('SmallAmp') ].
			"
			spec group: 'core' with: #('SmallGen').
			 ]
]
