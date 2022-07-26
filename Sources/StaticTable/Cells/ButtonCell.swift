//
//  ButtonCell.swift
//  StaticTable
//

#if os(iOS)

import Combine
import NPCombine
import NPKit
import UIKit

public class ButtonCell: TableCell {
	private var titleSubscription: AnyCancellable?
	private var buttonTextSubscription: AnyCancellable?
	private var buttonActionCancellation: Cancellation?

	public let titleLabel = NPLabel()
	public let button = CBButton(type: .system).with(translatesAutoresizingMaskIntoConstraints: false)

	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.contentView.addSubview(self.titleLabel)
		self.contentView.addSubview(self.button)

		NSLayoutConstraint.activate([
			self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1.5),
			self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2.5),
			self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 1.5),

			self.button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.button.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2.5),
			self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.button.trailingAnchor, multiplier: 2.5),
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func prepareForReuse() {
		super.prepareForReuse()
		self.titleSubscription = nil
		self.buttonTextSubscription = nil
		self.buttonActionCancellation?()
		self.buttonActionCancellation = nil
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
				if let tableView = self.tableView, let indexPath = self.indexPath {
					tableView.reloadRows(at: [indexPath], with: .none)
				}
			}
	}

	public var buttonText: String? {
		get { self.button.title(for: .normal) }
		set { self.button.setTitle(newValue, for: .normal) }
	}

	public func bindButtonText<P: Publisher>(to publisher: P) where P.Output == String {
		self.buttonTextSubscription = publisher
			.receive(on: DispatchQueue.mainIfNeeded)
			.sink { [weak self] _ in
				guard let self = self else { return }
				self.buttonTextSubscription = nil
			} receiveValue: { [weak self] newValue in
				guard let self = self else { return }
				self.buttonText = newValue
				self.tableView?.performBatchUpdates {}
			}
	}

	public func buttonAction(_ action: @escaping () -> Void) {
		self.buttonActionCancellation?()
		self.buttonActionCancellation = self.button.onTouchUpInside { _ in action() }
	}
}

#endif
