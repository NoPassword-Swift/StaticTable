//
//  IconSubtitleCell.swift
//  StaticTable
//

#if os(iOS)

import Color
import Combine
import Font
import NPKit
import UIKit

public class IconSubtitleCell: TableCell {
	private var iconSubscription: AnyCancellable?
	private var titleSubscription: AnyCancellable?
	private var subtitleSubscription: AnyCancellable?

	public let iconView: NPLabel = {
		let view = NPLabel()
		view.textAlignment = .center
		view.backgroundColor = Color.quaternarySystemFill
		view.layer.cornerRadius = 7
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

	private lazy var smallConstraints: [NSLayoutConstraint] = {
		return [
			self.iconView.widthAnchor.constraint(equalToConstant: 32),
			self.iconView.heightAnchor.constraint(equalToConstant: 32),

			self.iconContainer.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
			self.iconContainer.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2.5),
			self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.iconContainer.bottomAnchor, multiplier: 1),

			self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
			self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.iconContainer.trailingAnchor, multiplier: 1.5),
			self.contentView.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2.5),

			self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor),
			self.subtitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.iconContainer.trailingAnchor, multiplier: 1.5),
			self.contentView.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: self.subtitleLabel.trailingAnchor, multiplier: 2.5),
			self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.subtitleLabel.bottomAnchor, multiplier: 1),
		]
	}()
	private lazy var largeConstraints: [NSLayoutConstraint] = {
		return [
			self.iconView.widthAnchor.constraint(equalToConstant: self.titleLabel.font.lineHeight),
			self.iconView.heightAnchor.constraint(equalToConstant: self.titleLabel.font.lineHeight),

			self.iconContainer.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
			self.iconContainer.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2.5),

			self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
			self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.iconContainer.trailingAnchor, multiplier: 1.5),
			self.contentView.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2.5),
			self.titleLabel.centerYAnchor.constraint(equalTo: self.iconContainer.centerYAnchor),

			self.subtitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.iconContainer.bottomAnchor, multiplier: 0.5),
			self.subtitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2.5),
			self.contentView.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: self.subtitleLabel.trailingAnchor, multiplier: 2.5),
			self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.subtitleLabel.bottomAnchor, multiplier: 1),
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
			self.largeConstraints.activate()
		} else {
			self.smallConstraints.activate()
			self.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0) // 20 insets + 12 spacing (system spacing * 1.5) + 32 image
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func prepareForReuse() {
		super.prepareForReuse()
		self.iconSubscription = nil
		self.titleSubscription = nil
		self.subtitleSubscription = nil
	}

	// MARK: Set UI

	public var icon: String? {
		get { self.iconView.text }
		set { self.iconView.text = newValue }
	}

	public func bindIcon<P: Publisher>(to publisher: P) where P.Output == String {
		self.iconSubscription = publisher
			.receive(on: DispatchQueue.mainIfNeeded)
			.sink { _ in } receiveValue: { [weak self] newValue in
				guard let self = self else { return }
				self.icon = newValue
				self.tableView?.performBatchUpdates {}
			}
	}

	public var title: String? {
		get { self.titleLabel.text }
		set { self.titleLabel.text = newValue }
	}

	public func bindTitle<P: Publisher>(to publisher: P) where P.Output == String {
		self.titleSubscription = publisher
			.receive(on: DispatchQueue.mainIfNeeded)
			.sink { _ in } receiveValue: { [weak self] newValue in
				guard let self = self else { return }
				self.title = newValue
				self.tableView?.performBatchUpdates {}
			}
	}

	public var subtitle: String? {
		get { self.subtitleLabel.text }
		set { self.subtitleLabel.text = newValue }
	}

	public func bindSubtitle<P: Publisher>(to publisher: P) where P.Output == String {
		self.subtitleSubscription = publisher
			.receive(on: DispatchQueue.mainIfNeeded)
			.sink { _ in } receiveValue: { [weak self] newValue in
				guard let self = self else { return }
				self.subtitle = newValue
				self.tableView?.performBatchUpdates {}
			}
	}
}

#endif
