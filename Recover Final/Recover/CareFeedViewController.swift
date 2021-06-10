/*
 Copyright © 2021 Apple Inc. All rights reserved.

 Apple permits redistribution and use in source and binary forms, with or without
 modification, providing that you adhere to the following conditions:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions, and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions, and the following disclaimer in the documentation and
 other distributed materials.

 3. You may not use the name of the copyright holders nor the names of any contributors
 to endorse or promote products that derive from this software without specific prior
 written permission. Apple does not grant license to the trademarks of the copyright
 holders even if this software includes such marks.

 THE COPYRIGHT HOLDERS AND CONTRIBUTORS PROVIDE THIS SOFTWARE "AS IS”, AND DISCLAIM ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 OR CONSEQUENTIAL  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) WHATEVER THE CAUSE AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF YOU
 ADVISE THEM OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import CareKit
import CareKitStore
import CareKitUI
import ResearchKit
import UIKit
import os.log

final class CareFeedViewController: OCKDailyPageViewController,
                                    OCKSurveyTaskViewControllerDelegate {

    override func dailyPageViewController(
        _ dailyPageViewController: OCKDailyPageViewController,
        prepare listViewController: OCKListViewController,
        for date: Date) {

        checkIfOnboardingIsComplete { isOnboarded in

            guard isOnboarded else {

                let onboardCard = OCKSurveyTaskViewController(
                    taskID: TaskIDs.onboarding,
                    eventQuery: OCKEventQuery(for: date),
                    storeManager: self.storeManager,
                    survey: Surveys.onboardingSurvey(),
                    extractOutcome: { _ in [OCKOutcomeValue(Date())] }
                )

                onboardCard.surveyDelegate = self

                listViewController.appendViewController(
                    onboardCard,
                    animated: false
                )

                return
            }

            let isFuture = Calendar.current.compare(
                date,
                to: Date(),
                toGranularity: .day) == .orderedDescending

            self.fetchTasks(on: date) { tasks in
                tasks.compactMap {

                    let card = self.taskViewController(for: $0, on: date)
                    card?.view.isUserInteractionEnabled = !isFuture
                    card?.view.alpha = isFuture ? 0.4 : 1.0

                    return card

                }.forEach {
                    listViewController.appendViewController($0, animated: false)
                }
            }
        }
    }

    private func checkIfOnboardingIsComplete(_ completion: @escaping (Bool) -> Void) {

        var query = OCKOutcomeQuery()
        query.taskIDs = [TaskIDs.onboarding]

        storeManager.store.fetchAnyOutcomes(
            query: query,
            callbackQueue: .main) { result in

            switch result {

            case .failure:
                Logger.feed.error("Failed to fetch onboarding outcomes!")
                completion(false)

            case let .success(outcomes):
                completion(!outcomes.isEmpty)
            }
        }
    }

    private func fetchTasks(
        on date: Date,
        completion: @escaping([OCKAnyTask]) -> Void) {

        var query = OCKTaskQuery(for: date)
        query.excludesTasksWithNoEvents = true

        storeManager.store.fetchAnyTasks(
            query: query,
            callbackQueue: .main) { result in

            switch result {

            case .failure:
                Logger.feed.error("Failed to fetch tasks for date \(date)")
                completion([])

            case let .success(tasks):
                completion(tasks)
            }
        }
    }

    private func taskViewController(
        for task: OCKAnyTask,
        on date: Date) -> UIViewController? {

        switch task.id {

        case TaskIDs.checkIn:

            let survey = OCKSurveyTaskViewController(
                task: task,
                eventQuery: OCKEventQuery(for: date),
                storeManager: storeManager,
                survey: Surveys.checkInSurvey(),
                viewSynchronizer: SurveyViewSynchronizer(),
                extractOutcome: Surveys.extractAnswersFromCheckInSurvey
            )
            survey.surveyDelegate = self

            return survey

        case TaskIDs.rangeOfMotionCheck:
            let survey = OCKSurveyTaskViewController(
                task: task,
                eventQuery: OCKEventQuery(for: date),
                storeManager: storeManager,
                survey: Surveys.rangeOfMotionCheck(),
                extractOutcome: Surveys.extractRangeOfMotionOutcome
            )
            survey.surveyDelegate = self

            return survey

        default:
            return nil
        }
    }

    // MARK: SurveyTaskViewControllerDelegate

    func surveyTask(
        viewController: OCKSurveyTaskViewController,
        for task: OCKAnyTask,
        didFinish result: Result<ORKTaskViewControllerFinishReason, Error>) {

        if case let .success(reason) = result, reason == .completed {
            reload()
        }
    }

    func surveyTask(
        viewController: OCKSurveyTaskViewController,
        shouldAllowDeletingOutcomeForEvent event: OCKAnyEvent) -> Bool {

        event.scheduleEvent.start >= Calendar.current.startOfDay(for: Date())
    }
}

final class SurveyViewSynchronizer: OCKSurveyTaskViewSynchronizer {

    override func updateView(
        _ view: OCKInstructionsTaskView,
        context: OCKSynchronizationContext<OCKTaskEvents>) {

        super.updateView(view, context: context)

        if let event = context.viewModel.first?.first, event.outcome != nil {
            view.instructionsLabel.isHidden = false
            
            let pain = event.answer(kind: Surveys.checkInPainItemIdentifier)
            let sleep = event.answer(kind: Surveys.checkInSleepItemIdentifier)

            view.instructionsLabel.text = """
                Pain: \(Int(pain))
                Sleep: \(Int(sleep)) hours
                """
        } else {
            view.instructionsLabel.isHidden = true
        }
    }
}
