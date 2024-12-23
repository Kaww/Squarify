//
//  HapticsEngine.swift
//  Squarify
//
//  Created by KAWRANTIN on 23/12/2024.
//

import SwiftUI
import CoreHaptics

public class HapticsEngine: ObservableObject {

  private let notificationFeedbackGenerator: UINotificationFeedbackGenerator
  private let selectionFeedbackGenerator: UISelectionFeedbackGenerator

  public static let shared = HapticsEngine()

  private init() {
    notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    selectionFeedbackGenerator = UISelectionFeedbackGenerator()
  }

  // MARK: Public

  public func prepare() {
    notificationFeedbackGenerator.prepare()
    selectionFeedbackGenerator.prepare()
  }

  public func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
    notificationFeedbackGenerator.notificationOccurred(feedbackType)
  }

  public func selectionChanged() {
    selectionFeedbackGenerator.selectionChanged()
  }
}
