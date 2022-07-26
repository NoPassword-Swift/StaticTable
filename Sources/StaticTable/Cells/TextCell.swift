//
//  TextCell.swift
//  StaticTable
//

#if os(iOS)

import Color
import Combine
import NPKit
import UIKit

public class TextCell: TableCell {
	private var titleSubscription: AnyCancellable?

	public let titleLabel: NPLabel = {
		let view = NPLabel()
		view.setContentHuggingPriority(.defaultLow, for: .horizontal)
		return view
	}()

	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.contentView.addSubview(self.titleLabel)

		self.titleLabel.fillSuperviewSystemSpacing(multipliers: UIEdgeInsets(top: 1.5, left: 2.5, bottom: 1.5, right: 2.5)).activate()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func prepareForReuse() {
		super.prepareForReuse()
		self.alignment = .natural
		self.titleSubscription = nil
		self.setStatus(.normal)
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

	public var alignment: NSTextAlignment {
		get { self.titleLabel.textAlignment }
		set { self.titleLabel.textAlignment = newValue }
	}

	public func setStatus(_ status: TextCellStatus) {
		switch status {
			case .normal: self.titleLabel.textColor = Color.label
			case .destructive: self.titleLabel.textColor = Color.systemRed
			case .hightlighted: self.titleLabel.textColor = Color.systemBlue
		}
	}
}

public enum TextCellStatus {
	case normal
	case destructive
	case hightlighted
}

#endif
