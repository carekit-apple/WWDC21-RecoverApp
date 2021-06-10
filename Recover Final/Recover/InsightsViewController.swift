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

import UIKit
import CareKit
import CareKitUI
import ResearchKit

final class InsightsViewController:
    OCKListViewController,
    OCKFeaturedContentViewDelegate,
    ORKTaskViewControllerDelegate {

    let storeManager: OCKSynchronizedStoreManager

    init(storeManager: OCKSynchronizedStoreManager) {
        self.storeManager = storeManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true

        // A spacer view.
        appendView(UIView(), animated: false)

        let kneeModelView = OCKFeaturedContentView(imageOverlayStyle: .dark)
        kneeModelView.delegate = self
        kneeModelView.label.text = "About the meniscus"
        kneeModelView.label.textColor = .systemBackground
        kneeModelView.imageView.image = UIImage(named: "knee")
        appendView(kneeModelView, animated: true)

        let painSeries = OCKDataSeriesConfiguration(
            taskID: TaskIDs.checkIn,
            legendTitle: "Pain (1-10)",
            gradientStartColor: #colorLiteral(red: 1, green: 0.462745098, blue: 0.368627451, alpha: 1),
            gradientEndColor: #colorLiteral(red: 1, green: 0.462745098, blue: 0.368627451, alpha: 1),
            markerSize: 10,
            eventAggregator: .custom({ events in
                events
                    .first?
                    .answer(kind: Surveys.checkInPainItemIdentifier)
                ?? 0
            })
        )

        let sleepSeries = OCKDataSeriesConfiguration(
            taskID: TaskIDs.checkIn,
            legendTitle: "Sleep (hours)",
            gradientStartColor: UIColor.systemBlue,
            gradientEndColor: UIColor.systemBlue,
            markerSize: 10,
            eventAggregator: .custom({ events in
                events
                    .first?
                    .answer(kind: Surveys.checkInSleepItemIdentifier)
                ?? 0
            })
        )

        let barChart = OCKCartesianChartViewController(
            plotType: .bar,
            selectedDate: Date(),
            configurations: [painSeries, sleepSeries],
            storeManager: storeManager
        )

        appendViewController(barChart, animated: false)

        let rangeSeries = OCKDataSeriesConfiguration(
            taskID: TaskIDs.rangeOfMotionCheck,
            legendTitle: "Range of Motion (degrees)",
            gradientStartColor: view.tintColor,
            gradientEndColor: view.tintColor,
            markerSize: 3,
            eventAggregator: .custom({ events in
                events
                    .first?
                    .answer(kind: #keyPath(ORKRangeOfMotionResult.range))
                ?? 0
            })
        )

        let scatterChart = OCKCartesianChartViewController(
            plotType: .scatter,
            selectedDate: Date(),
            configurations: [rangeSeries],
            storeManager: storeManager
        )

        appendViewController(scatterChart, animated: false)

        // A spacer view.
        appendView(UIView(), animated: false)
    }

    // MARK: OCKFeaturedContentViewDelegate

    func didTapView(_ view: OCKFeaturedContentView) {

        let humanModelTask = Surveys.kneeModel()

        let taskViewController = ORKTaskViewController(
            task: humanModelTask,
            taskRun: nil
        )

        taskViewController.delegate = self

        present(taskViewController, animated: true, completion: nil)
    }

    // MARK: ORKTaskViewControllerDelegate

    func taskViewController(
        _ taskViewController: ORKTaskViewController,
        didFinishWith reason: ORKTaskViewControllerFinishReason,
        error: Error?) {

        taskViewController.dismiss(animated: true, completion: nil)
    }
}
