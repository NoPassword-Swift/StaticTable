//
//  ValueCell.swift
//  StaticTable
//

#if os(iOS)

import Color
import Combine
import NPKit
import UIKit

public class ValueCell: TableCell {
	private var titleSubscription: AnyCancellable?
	private var valueSubscription: AnyCancellable?

	public let titleLabel = NPLabel()
	public let valueLabel = NPLabel()

	private var isSmallConstraints: Bool = false
	private lazy var smallConstraints: [NSLayoutConstraint] = {
		return [
			self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1.5),
			self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2.5),
			self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 1.5),

			self.valueLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1.5),
			self.valueLabel.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 1),
			self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.valueLabel.trailingAnchor, multiplier: 2.5),
			self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.valueLabel.bottomAnchor, multiplier: 1.5),
		]
	}()
	private lazy var largeConstraints: [NSLayoutConstraint] = {
		return [
			self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1.5),
			self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2.5),
			self.contentView.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2.5),

			self.valueLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 3),
			self.valueLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2.5),
			self.contentView.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: self.valueLabel.trailingAnchor, multiplier: 2.5),
			self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.valueLabel.bottomAnchor, multiplier: 1.5),
		]
	}()

	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.contentView.addSubview(self.titleLabel)
		self.contentView.addSubview(self.valueLabel)

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

	public override func prepareForReuse() {
		super.prepareForReuse()
		self.titleSubscription = nil
		self.valueSubscription = nil
	}

	public override func updateConstraints() {
		let textWidth = self.titleLabel.singleLineTextWidth() + self.valueLabel.singleLineTextWidth() + 48 // 20 insets + 8 spacing (system spacing)
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

	public func bindTitle<P: Publisher>(to publisher: P) where P.Output == String {
		self.titleSubscription = publisher
			.receive(on: DispatchQueue.mainIfNeeded)
			.sink { _ in } receiveValue: { [weak self] newValue in
				guard let self = self else { return }
				self.title = newValue
				self.tableView?.performBatchUpdates {}
			}
	}

	public var value: String? {
		get { self.valueLabel.text }
		set { self.valueLabel.text = newValue }
	}

	public func bindValue<P: Publisher>(to publisher: P) where P.Output == String {
		self.valueSubscription = publisher
			.receive(on: DispatchQueue.mainIfNeeded)
			.sink { _ in } receiveValue: { [weak self] newValue in
				guard let self = self else { return }
				self.value = newValue
				self.tableView?.performBatchUpdates {}
			}
	}
}

#endif
