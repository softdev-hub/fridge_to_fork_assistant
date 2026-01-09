import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/models/profile.dart';
import 'package:fridge_to_fork_assistant/controllers/profile_controller.dart';
import 'package:fridge_to_fork_assistant/views/auth/edit_profile_view.dart';
import 'package:fridge_to_fork_assistant/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
	const ProfilePage({super.key});

	@override
	State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
	static const Color primaryColor = Color(0xFF4CAF50);
	static const Color backgroundLight = Color(0xFFF8FAF7);

	final ProfileController _profileCProfileController = ProfileController();
	final AuthService _authService = AuthService();

	Profile? _profile;
	bool _loading = true;

	@override
	void initState() {
		super.initState();
		_loadProfile();
	}

	Future<void> _loadProfile() async {
		setState(() => _loading = true);
		final profile = await _profileCProfileController.getProfile();
		setState(() {
			_profile = profile;
			_loading = false;
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: backgroundLight,
			appBar: AppBar(
				backgroundColor: Colors.white,
				elevation: 0,
				centerTitle: true,
				leading: IconButton(
					icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
					onPressed: () => Navigator.of(context).maybePop(),
				),
				title: const Text('Hồ sơ người dùng', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
			),
			body: SafeArea(
				child: _loading
						? const Center(child: CircularProgressIndicator())
						: SingleChildScrollView(
								child: Padding(
									padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
									child: Column(
										children: [
											// Avatar
											Column(
												children: [
													Stack(
														children: [
															Container(
																padding: const EdgeInsets.all(6),
																decoration: const BoxDecoration(
																	color: Colors.white,
																	shape: BoxShape.circle,
																),
																child: CircleAvatar(
																	radius: 48,
																	backgroundImage: _profile?.avatarUrl != null ? NetworkImage(_profile!.avatarUrl!) as ImageProvider : null,
																	backgroundColor: const Color(0xFFEFEFEF),
																	child: _profile?.avatarUrl == null ? const Icon(Icons.person, size: 48, color: Colors.grey) : null,
																),
															),
															Positioned(
																right: 0,
																bottom: 0,
																child: Container(
																	width: 34,
																	height: 34,
																	decoration: BoxDecoration(
																		color: primaryColor,
																		shape: BoxShape.circle,
																		border: Border.all(color: backgroundLight, width: 2),
																	),
																),
															),
														],
													),
												],
											),

											const SizedBox(height: 20),

											// Info cards (use profile data if available)
											Column(
												children: [
													Container(
														width: double.infinity,
														padding: const EdgeInsets.all(14),
														decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																const Text('Họ và tên', style: TextStyle(color: Colors.grey, fontSize: 12)),
																const SizedBox(height: 8),
																Text(_profile?.name ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
															],
														),
													),
													const SizedBox(height: 12),
													Container(
														width: double.infinity,
														padding: const EdgeInsets.all(14),
														decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																const Text('Email', style: TextStyle(color: Colors.grey, fontSize: 12)),
																const SizedBox(height: 8),
																Text(_authService.getCurrentUserEmail() ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
															],
														),
													),
												],
											),

											const SizedBox(height: 20),

											// Edit profile button
											SizedBox(
												width: double.infinity,
												height: 52,
												child: ElevatedButton.icon(
													onPressed: () async {
														final result = await Navigator.of(context).push<bool>(
															MaterialPageRoute(builder: (_) => const EditProfilePage()),
														);
														// If the edit screen returned true, reload profile
														if (result == true) {
															await _loadProfile();
														}
													},
													icon: const Icon(Icons.edit, color: Colors.white),
													label: const Text('Chỉnh sửa hồ sơ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
													style: ElevatedButton.styleFrom(
														backgroundColor: primaryColor,
														shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
													),
												),
											),

											const SizedBox(height: 16),

											// Options list
											Container(
												width: double.infinity,
												decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
												child: Column(
													children: [
														InkWell(
															onTap: () {
																// TODO: change password
															},
															child: Padding(
																padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
																child: Row(
																	mainAxisAlignment: MainAxisAlignment.spaceBetween,
																	children: [
																		Row(
																			children: const [
																				Icon(Icons.lock_outline, color: Colors.grey),
																				SizedBox(width: 12),
																				Text('Thay đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.w600)),
																			],
																		),
																		const Icon(Icons.chevron_right, color: Colors.grey),
																	],
																),
															),
														),
														Container(height: 1, color: const Color(0xFFF1F1F1)),
														InkWell(
															onTap: () {
																// TODO: app settings
															},
															child: Padding(
																padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
																child: Row(
																	mainAxisAlignment: MainAxisAlignment.spaceBetween,
																	children: [
																		Row(
																			children: const [
																				Icon(Icons.settings, color: Colors.grey),
																				SizedBox(width: 12),
																				Text('Cài đặt ứng dụng', style: TextStyle(fontWeight: FontWeight.w600)),
																			],
																		),
																		const Icon(Icons.chevron_right, color: Colors.grey),
																	],
																),
															),
														),
													],
												),
											),

											const SizedBox(height: 24),
										],
									),
								),
							),
			),
		);
	}
}
