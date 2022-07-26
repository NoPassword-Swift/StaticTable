//
//  ToggleCell.swift
//  StaticTable
//

#if os(iOS)

import Combine
import NPCombine
import NPKit
import UIKit

public class ToggleCell: TableCell {
	private var titleSubscription: AnyCancellable?

	public let titleLabel: NPLabel = {
		let view = NPLabel()
		view.setContentHuggingPriority(.defaultLow, for: .horizontal)
		return view
	}()
	public let toggle = CBToggle()

	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.toggle.isOn = false
		self.toggle.isEnabled = false

		self.contentView.addSubview(self.titleLabel)
		self.contentView.addSubview(self.toggle)

		NSLayoutConstraint.activate([
			self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1.5),
			self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2.5),
			self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 1.5),

			self.toggle.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.toggle.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2.5),
			self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.toggle.trailingAnchor, multiplier: 2.5),
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func prepareForReuse() {
		super.prepareForReuse()
		self.titleSubscription = nil
		self.toggle.stopTracking()
		self.toggle.isOn = false
		self.toggle.isEnabled = true
	}

	// MARK: Set UI

	public var title: String? {
		get { self.titleLabel.text }
		set { self.titleLabel.text = newValue }
	}

	public func bindTitle<P: Publisher>(to publisher: P) where P.Output == String {
		self.titleSubscription = publisher
			.receive(on: DispatchQueue.mainIfNeeded)
			.sink { [weak self] _ in
				guard let self = self else { return }
				self.titleSubscription = nil
			} receiveValue: { [weak self] newValue in
				guard let self = self else { return }
				self.title = newValue
				self.tableView?.performBatchUpdates {}
			}
	}

	public var isOn: Bool {
		get { self.toggle.isOn }
		set { self.toggle.isOn = newValue }
	}

	public var isEnabled: Bool {
		get { self.toggle.isEnabled }
		set { self.toggle.isEnabled = newValue }
	}

	public func trackToggle<S: Subject>(to subject: S) where S.Output == Bool {
		self.toggle.track(subject: subject)
	}
}

#endif
