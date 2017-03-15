//
//  ExampleSource.swift
//  transtest
//
//  Created by Katie Bogdanska on 27/02/17.
//  Copyright © 2017 Robert-Hein Hooijmans. All rights reserved.
//

import Transition

class ExampleSource: TransitionsSource {
    
    func transitionFor(operationContext: TransitionOperationContext, interactionController: TransitionInteractionController?) -> Transition {
        return Transition(duration: 1, animation: ExampleAnimation())
    }
}
