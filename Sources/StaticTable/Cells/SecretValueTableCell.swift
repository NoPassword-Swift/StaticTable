//
//  SecretValueTableCell.swift
//  StaticTable
//

#if os(iOS)

import Color
import CoreCombine
import Font
import NPCombine
import NPKit
import UIKit

public class SecretValueTableCell: StaticTableCell {
	public let titleLabel = NPLabel()

	public let secretLabel: NPLabel = {
		let view = NPLabel()
		view.textColor = Color.secondaryLabel
		return view
	}()

	public var isSecret: Bool { self.secretView.isSecret }
	private let secretView: SecretableView

	private var isSmallConstraints: Bool = false
	private lazy var smallConstraints: [NSLayoutConstraint] = {
		return [
			self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1.5),
			self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2.5),
			self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 1.5),

			self.secretView.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1.5),
			self.secretView.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 1),
			self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.secretView.trailingAnchor, multiplier: 2.5),
			self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.secretView.bottomAnchor, multiplier: 1.5),
		]
	}()
	private lazy var largeConstraints: [NSLayoutConstraint] = {
		return [
			self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1.5),
			self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2.5),
			self.contentView.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2.5),

			self.secretView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 3),
			self.secretView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2.5),
			self.contentView.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: self.secretView.trailingAnchor, multiplier: 2.5),
			self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.secretView.bottomAnchor, multiplier: 1.5),
		]
	}()

	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		self.secretView = SecretableView(view: self.secretLabel)

		super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.contentView.addSubview(self.titleLabel)
		self.contentView.addSubview(self.secretView)

		if self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
			self.isSmallConstraints = false
			self.largeConstraints.activate()
		} else {
			self.isSmallConstraints = true
			self.smallConstraints.activate()
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func updateConstraints() {
		let textWidth = self.titleLabel.singleLineTextWidth() + self.secretLabel.singleLineTextWidth() + 48 // 20 insets + 8 spacing (system spacing)
		if textWidth >= self.contentView.frame.width && self.isSmallConstraints {
			self.isSmallConstraints = false
			self.smallConstraints.deactivate()
			self.largeConstraints.activate()
		} else if textWidth < self.contentView.frame.width && !self.isSmallConstraints {
			self.isSmallConstraints = true
			self.largeConstraints.deactivate()
			self.smallConstraints.activate()
		}
		super.updateConstraints()
	}

	// MARK: Set UI

	public var title: String? {
		get { self.titleLabel.text }
		set { self.titleLabel.text = newValue }
	}

	public var secret: String? {
		get { self.secretLabel.text }
		set {
			if let newValue = newValue {
				self.secretView.makeSecret()
				self.secretLabel.font = Font.body
				self.secretLabel.text = newValue
			} else {
				self.secretView.makeNotSecret()
				self.secretLabel.font = Font.preferredMonoFont(for: .body, weight: .regular)
				self.secretLabel.text = "● ● ● ● ● ● ● ●"
			}
		}
	}

	public func updateSettings(enableAPI: CBSubject<Bool>? = nil, breakAPI: CBSubject<Bool>? = nil) {
		self.secretView.updateSettings(enableAPI: enableAPI, breakAPI: breakAPI)
	}
}

#endif
