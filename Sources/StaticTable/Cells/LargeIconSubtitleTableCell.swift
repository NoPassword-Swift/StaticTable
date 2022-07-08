//
//  LargeIconSubtitleTableCell.swift
//  StaticTable
//

#if os(iOS)

import Color
import Font
import NPKit
import UIKit

public class LargeIconSubtitleTableCell: StaticTableCell {
	public let iconView: NPLabel = {
		let view = NPLabel()
		view.textAlignment = .center
		view.backgroundColor = Color.quaternarySystemFill
		view.layer.cornerRadius = 15
		view.layer.cornerCurve = CALayerCornerCurve.continuous
		view.clipsToBounds = true
		return view
	}()

	public let iconContainer = NPView()

	public let titleLabel: NPLabel = {
		let view = NPLabel()
		view.font = Font.preferredFont(for: .body, weight: .bold)
		return view
	}()

	public let subtitleLabel: NPLabel = {
		let view = NPLabel()
		view.textColor = Color.secondaryLabel
		view.font = Font.footnote
		return view
	}()

	private var isSmallConstraints: Bool = false
	private lazy var smallConstraints: [NSLayoutConstraint] = {
		return [
			self.iconView.widthAnchor.constraint(equalToConstant: 60),
			self.iconView.heightAnchor.constraint(equalToConstant: 60),

			self.iconContainer.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1.5),
			self.iconContainer.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2.5),
			self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.iconContainer.bottomAnchor, multiplier: 1.5),

			self.titleLabel.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1.5),
			self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.iconContainer.trailingAnchor, multiplier: 1.5),
			self.contentView.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2.5),
			self.titleLabel.firstBaselineAnchor.constraint(equalTo: self.iconContainer.centerYAnchor),

			self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 3),
			self.subtitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.iconContainer.trailingAnchor, multiplier: 1.5),
			self.contentView.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: self.subtitleLabel.trailingAnchor, multiplier: 2.5),
			self.contentView.bottomAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: self.subtitleLabel.bottomAnchor, multiplier: 1.5),
		]
	}()
	private lazy var largeConstraints: [NSLayoutConstraint] = {
		// FIXME: If the text is long and the font size is very large, self.iconContainer will grow vertically - it would be nice if the titleLabel wrapped around the icon
		return [
			self.iconView.widthAnchor.constraint(equalToConstant: 60),
			self.iconView.heightAnchor.constraint(equalToConstant: 60),

			self.iconContainer.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1.5),
			self.iconContainer.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2.5),

			self.titleLabel.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1.5),
			self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.iconContainer.trailingAnchor, multiplier: 1.5),
			self.contentView.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2.5),
			self.titleLabel.centerYAnchor.constraint(equalTo: self.iconContainer.centerYAnchor),

			self.subtitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.iconContainer.bottomAnchor, multiplier: 1.5),
			self.subtitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2.5),
			self.contentView.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: self.subtitleLabel.trailingAnchor, multiplier: 2.5),
			self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.subtitleLabel.bottomAnchor, multiplier: 1.5),
		]
	}()

	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.iconContainer.addSubview(self.iconView)
		self.contentView.addSubview(self.iconContainer)
		self.contentView.addSubview(self.titleLabel)
		self.contentView.addSubview(self.subtitleLabel)

		self.iconView.centerResistingCompressionInSuperview().activate()
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
		let titleWidth = self.titleLabel.singleLineTextWidth() + 108 // 20 insets + 8 spacing (system spacing) + 60 image
		let subtitleWidth = self.subtitleLabel.singleLineTextWidth() + 108 // 20 insets + 8 spacing (system spacing) + 60 image
		if (titleWidth > self.contentView.frame.width || subtitleWidth > self.contentView.frame.width) && self.isSmallConstraints {
			self.isSmallConstraints = false
			self.smallConstraints.deactivate()
			self.largeConstraints.activate()
		}
		super.updateConstraints()
	}

	// MARK: Set UI

	public var image: String? {
		get { self.iconView.text }
		set { self.iconView.text = newValue }
	}

	public var title: String? {
		get { self.titleLabel.text }
		set { self.titleLabel.text = newValue }
	}

	public var subtitle: String? {
		get { self.subtitleLabel.text }
		set { self.subtitleLabel.text = newValue }
	}
}

#endif
