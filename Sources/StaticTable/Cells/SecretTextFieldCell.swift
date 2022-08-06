//
//  SecretTextFieldCell.swift
//  StaticTable
//

#if os(iOS)

import Color
import Combine
import CoreCombine
import Font
import NPCombine
import NPKit
import UIKit

public class SecretTextFieldCell: TableCell {
	private var titleSubscription: AnyCancellable?
	private var textFieldSubscription: AnyCancellable?
	private var textFieldSend: ((String) -> Void)?

	public let titleLabel: NPLabel = {
		let view = NPLabel()
		view.font = Font.footnote
		return view
	}()
	public let textField: NPTextField = {
		let view = NPTextField()
		view.borderStyle = .none
		view.returnKeyType = .done
		return view
	}()
	public let showButton: UIButton = {
		let view = NPButton.make()
		view.setImage(UIImage(systemName: "eye")!, for: .normal)
		view.imageView?.contentMode = .scaleAspectFit
		view.setContentHuggingPriority(.required, for: .horizontal)
		return view
	}()

	private let secretView: SecretableView

	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		self.secretView = SecretableView(view: self.textField)

		super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.textField.delegate = self

		self.showButton.onTouchUpInside { [weak self] button in
			guard let self = self else { return }
			switch self.secretView.isSecret {
				case true:
					self.textField.isSecureTextEntry = true
					self.secretView.makeNotSecret()
					self.showButton.setImage(UIImage(systemName: "eye")!, for: .normal)
				case false:
					self.secretView.makeSecret()
					self.textField.isSecureTextEntry = false
					self.showButton.setImage(UIImage(systemName: "eye.slash")!, for: .normal)
			}
		}

		self.contentView.addSubview(self.titleLabel)
		self.contentView.addSubview(self.secretView)
		self.contentView.addSubview(self.showButton)

		NSLayoutConstraint.activate([
			self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1.5),
			self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2.5),

			self.secretView.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 1),
			self.secretView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2.5),
			self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.secretView.bottomAnchor, multiplier: 1.5),

			self.showButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
			self.showButton.heightAnchor.constraint(equalTo: self.contentView.heightAnchor),
			self.showButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 1.5),
			self.showButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.secretView.trailingAnchor, multiplier: 1.5),
			self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.showButton.trailingAnchor, multiplier: 2.5),
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func prepareForReuse() {
		super.prepareForReuse()
		self.titleSubscription = nil
		self.placeholder = nil
		self.isSecure = false
		self.textFieldSubscription = nil
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

	public var placeholder: String? {
		get { self.textField.placeholder }
		set { self.textField.placeholder = newValue }
	}

	public var isSecure: Bool {
		get { self.textField.isSecureTextEntry }
		set { self.textField.isSecureTextEntry = newValue }
	}

	public func trackTextField<S: Subject>(to subject: S) where S.Output == String {
		self.textFieldSubscription = subject
			.receive(on: DispatchQueue.mainIfNeeded)
			.sink { [weak self] _ in
				guard let self = self else { return }
				self.textFieldSend = nil
			} receiveValue: { [weak self] newValue in
				guard let self = self else { return }
				self.textField.text = newValue
				if self.textField.placeholder == newValue {
					self.textField.text = ""
				}
				self.tableView?.performBatchUpdates {}
			}
		self.textFieldSend = subject.send
	}

	public func updateSettings(enableAPI: CBSubject<Bool>? = nil, breakAPI: CBSubject<Bool>? = nil) {
		self.secretView.updateSettings(enableAPI: enableAPI, breakAPI: breakAPI)
	}
}

extension SecretTextFieldCell: UITextFieldDelegate {
	public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if let sender = self.textFieldSend {
			let textFieldString = (textField.text ?? "") as NSString
			let newString = textFieldString.replacingCharacters(in: range, with: string)
			if newString.isEmpty {
				sender(textField.placeholder ?? "")
			} else {
				sender(newString)
			}
		}
		return false
	}

	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

#endif
