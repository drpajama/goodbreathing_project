//
//  ViewController.swift
//  researchkit_project
//
//  Created by JoongHeum Park on 3/26/18.
//  Copyright © 2018 JoongHeum Park. All rights reserved.
//

import UIKit
import ResearchKit

class ViewController: UIViewController, ORKTaskViewControllerDelegate {
    
    var prescreenCompleted = false
    var participantEligible = true
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        
        
        let result = taskViewController.result
        let ageStepResult = result.stepResult(forStepIdentifier: "ageQuestion")
        let ageBoolResult = ageStepResult?.firstResult as! ORKBooleanQuestionResult
        
        prescreenCompleted = true
        
        if (ageBoolResult.booleanAnswer?.boolValue == true ) {
            print ("Eligible")
            participantEligible = true
        } else {
            print ("Not Eligible")
            participantEligible = false
        }
        
        dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        if !prescreenCompleted {
            self.prescreenParticipant()
        } else {
            // completed
            
            if participantEligible == true {
                // MOVE to CONSENT
                
                self.showConsent()
                
            } else {
                // SHOW A MESSAGE FAILED PRESCREEN
                
                let failed = ORKInstructionStep(identifier: "failed")
                failed.title = "You failed prescreen"
                failed.detailText = "Loser!!"
                let failedTask = ORKOrderedTask(identifier: "prescreeningTask", steps: [failed])
                let failedTaskViewController = ORKTaskViewController(task: failedTask, taskRun: nil)
                present(failedTaskViewController, animated: true, completion: nil)
            }
        }
    }
    
    func showConsent() {
        let consentDocument = ORKConsentDocument()
        let privacy = ORKConsentSection(type: .privacy)
        privacy.summary = "How is my data managed? We make money with your data!"
        privacy.title = "Privacy"
        privacy.content = "We will collect your data (including social security) and sell the data to Google and Walmart. "
        consentDocument.sections = [privacy]
    
        
        let privacyStep = ORKVisualConsentStep(identifier: "privacyStep", document: consentDocument)
        let signitureStep = ORKSignatureStep(identifier: "signiture")
        
        let consentTask = ORKOrderedTask(identifier: "consentTask", steps: [privacyStep, signitureStep])
    
        
        let consentTaskViewController = ORKTaskViewController(task: consentTask, taskRun: nil)
        
        consentTaskViewController.delegate = self
        present(consentTaskViewController, animated: true, completion: nil)
    }
    
    func prescreenParticipant() {
        
        
        let intro = ORKInstructionStep(identifier: "intro")
        intro.title = "Welcome to my GoodBreathingj"
        intro.detailText = "CUMC mHealth"
        
        let ageQuestionStep = ORKQuestionStep(identifier: "ageQuestion")
        ageQuestionStep.title = "Are you 18 years or older?"
        ageQuestionStep.answerFormat = ORKAnswerFormat.booleanAnswerFormat()
        ageQuestionStep.isOptional = false
        
        let fitnessQuestionStep = ORKQuestionStep(identifier: "fitnessQuestion")
        fitnessQuestionStep.title = "Have you diagnosed with any of folowing: "
        //fitnessQuestionStep.answerFormat = ORKAnswerFormat.
        
        let choice1 = ORKTextChoice(text:"COPD", value:1 as NSNumber)
        let choice2 = ORKTextChoice(text:"Asthma", value:2 as NSNumber)
        let choice3 = ORKTextChoice(text:"Interstial Lung Disease", value:3 as NSNumber)
        let choice4 = ORKTextChoice(text:"Do not remember / Do not understand the question", value:4 as NSNumber)
        let choice5 = ORKTextChoice(text:"Evaluated for breathing issues, but the diagnosis have never been clear", value:5 as NSNumber)
        let choice6 = ORKTextChoice(text:"Other", value:6 as NSNumber)
        
        
        let exerciseChoices = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: [choice1, choice2, choice3, choice4, choice5, choice6])
        
        fitnessQuestionStep.answerFormat = exerciseChoices
        
        let prescreenTask = ORKOrderedTask(identifier: "prescreeningTask", steps: [intro, ageQuestionStep, fitnessQuestionStep])
        let prescreenTaskViewController = ORKTaskViewController(task: prescreenTask, taskRun: nil)
        
        prescreenTaskViewController.delegate = self
        
        
        
        present(prescreenTaskViewController, animated: true, completion: nil)
    }

}

