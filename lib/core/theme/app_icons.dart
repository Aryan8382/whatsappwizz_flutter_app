import 'package:flutter/material.dart';

/// Central design system for icons across the entire WhatsApp Wiz application.
/// Ensures 100% unified visual style: polished rounded stroke geometry,
/// consistent proportions, 24x24 base grid, and harmonized sizing tokens.
class AppIcons {
  AppIcons._();

  // Consistent Size Standards
  static const double sizeXs = 14.0;
  static const double sizeSm = 16.0;
  static const double sizeMd = 20.0;
  static const double sizeLg = 22.0;
  static const double sizeXl = 26.0;

  // Bottom Navigation & Core Modules
  static const IconData dashboard = Icons.grid_view_rounded;
  static const IconData chatbot = Icons.smart_toy_rounded;
  static const IconData inbox = Icons.chat_bubble_rounded;
  static const IconData templates = Icons.description_rounded;
  static const IconData broadcasts = Icons.campaign_rounded;
  static const IconData contacts = Icons.people_alt_rounded;
  static const IconData automation = Icons.flash_on_rounded;
  static const IconData flows = Icons.account_tree_rounded;
  static const IconData customFields = Icons.tune_rounded;
  static const IconData media = Icons.image_rounded;
  static const IconData dnd = Icons.phone_disabled_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData reports = Icons.bar_chart_rounded;
  static const IconData wallet = Icons.account_balance_wallet_rounded;

  // Header, Navigation & Shell
  static const IconData menu = Icons.menu_rounded;
  static const IconData notifications = Icons.notifications_rounded;
  static const IconData shield = Icons.shield_rounded;
  static const IconData logout = Icons.logout_rounded;
  static const IconData close = Icons.close_rounded;

  // Actions & Controls
  static const IconData add = Icons.add_rounded;
  static const IconData sync = Icons.refresh_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData send = Icons.send_rounded;
  static const IconData pause = Icons.pause_rounded;
  static const IconData play = Icons.play_arrow_rounded;
  static const IconData analytics = Icons.trending_up_rounded;
  static const IconData check = Icons.done_rounded;
  static const IconData checkCircle = Icons.check_circle_rounded;
  static const IconData alertCircle = Icons.error_outline_rounded;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData filter = Icons.filter_list_rounded;
  static const IconData trash = Icons.delete_outline_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData info = Icons.info_outline_rounded;
  static const IconData chevronRight = Icons.chevron_right_rounded;
  static const IconData chevronLeft = Icons.chevron_left_rounded;
  static const IconData chevronDown = Icons.keyboard_arrow_down_rounded;
  static const IconData moreVertical = Icons.more_vert_rounded;
  static const IconData arrowUpRight = Icons.north_east_rounded;
  static const IconData arrowDownLeft = Icons.south_west_rounded;
  static const IconData messageCircle = Icons.forum_rounded;
  static const IconData copy = Icons.content_copy_rounded;
  static const IconData externalLink = Icons.open_in_new_rounded;
}

/// Compatibility alias providing unified, polished icons matching the design system.
/// Every icon uses Flutter's polished rounded vector glyphs to prevent package class-finality errors.
class LucideIcons {
  LucideIcons._();

  static const IconData arrowLeft = Icons.arrow_back_rounded;
  static const IconData arrowRight = Icons.arrow_forward_rounded;
  static const IconData arrowDownLeft = Icons.south_west_rounded;
  static const IconData arrowUpRight = Icons.north_east_rounded;
  static const IconData arrowDown = Icons.arrow_downward_rounded;
  static const IconData arrowUp = Icons.arrow_upward_rounded;

  static const IconData phone = Icons.phone_rounded;
  static const IconData smartphone = Icons.smartphone_rounded;
  static const IconData moreVertical = Icons.more_vert_rounded;

  static const IconData user = Icons.person_rounded;
  static const IconData users = Icons.people_alt_rounded;
  static const IconData userPlus = Icons.person_add_rounded;
  static const IconData userCheck = Icons.how_to_reg_rounded;

  static const IconData rotateCcw = Icons.replay_rounded;
  static const IconData refreshCw = Icons.refresh_rounded;

  static const IconData bell = Icons.notifications_rounded;
  static const IconData bellRing = Icons.notifications_active_rounded;

  static const IconData bookOpen = Icons.menu_book_rounded;
  static const IconData layoutGrid = Icons.grid_view_rounded;
  static const IconData briefcase = Icons.work_rounded;
  static const IconData package = Icons.inventory_2_rounded;
  static const IconData shoppingBag = Icons.shopping_bag_rounded;
  static const IconData cpu = Icons.memory_rounded;

  static const IconData fileText = Icons.description_rounded;
  static const IconData camera = Icons.camera_alt_rounded;
  static const IconData image = Icons.image_rounded;
  static const IconData imageOff = Icons.broken_image_rounded;
  static const IconData headphones = Icons.headphones_rounded;
  static const IconData music = Icons.audiotrack_rounded;
  static const IconData video = Icons.videocam_rounded;
  static const IconData wand2 = Icons.auto_awesome_rounded;
  static const IconData mic = Icons.mic_rounded;
  static const IconData paperclip = Icons.attach_file_rounded;
  static const IconData keyboard = Icons.keyboard_rounded;
  static const IconData smile = Icons.sentiment_satisfied_alt_rounded;

  static const IconData play = Icons.play_arrow_rounded;
  static const IconData pause = Icons.pause_rounded;
  static const IconData playCircle = Icons.play_circle_rounded;
  static const IconData stopCircle = Icons.stop_circle_rounded;

  static const IconData download = Icons.download_rounded;
  static const IconData upload = Icons.upload_rounded;
  static const IconData uploadCloud = Icons.cloud_upload_rounded;

  static const IconData mapPin = Icons.location_on_rounded;
  static const IconData zoomIn = Icons.zoom_in_rounded;

  static const IconData check = Icons.done_rounded;
  static const IconData checkCheck = Icons.done_all_rounded;
  static const IconData checkCircle = Icons.check_circle_rounded;
  static const IconData checkCircle2 = Icons.check_circle_rounded;

  static const IconData alertCircle = Icons.error_outline_rounded;
  static const IconData alertTriangle = Icons.warning_amber_rounded;
  static const IconData helpCircle = Icons.help_outline_rounded;

  static const IconData lock = Icons.lock_rounded;
  static const IconData clock = Icons.access_time_rounded;
  static const IconData hourglass = Icons.hourglass_bottom_rounded;

  static const IconData zap = Icons.flash_on_rounded;
  static const IconData webhook = Icons.webhook_rounded;
  static const IconData mousePointerClick = Icons.touch_app_rounded;
  static const IconData bot = Icons.smart_toy_rounded;

  static const IconData ban = Icons.block_rounded;
  static const IconData trash2 = Icons.delete_outline_rounded;
  static const IconData edit2 = Icons.edit_rounded;
  static const IconData penTool = Icons.draw_rounded;

  static const IconData copy = Icons.content_copy_rounded;
  static const IconData building = Icons.business_rounded;
  static const IconData hammer = Icons.construction_rounded;
  static const IconData tag = Icons.label_rounded;
  static const IconData pieChart = Icons.pie_chart_rounded;
  static const IconData code = Icons.code_rounded;
  static const IconData cloud = Icons.cloud_done_rounded;
  static const IconData cloudUpload = Icons.cloud_upload_rounded;
  static const IconData cloudCheck = Icons.cloud_done_rounded;
  static const IconData barChart2 = Icons.bar_chart_rounded;

  static const IconData eye = Icons.visibility_rounded;
  static const IconData eyeOff = Icons.visibility_off_rounded;
  static const IconData mail = Icons.mail_rounded;
  static const IconData mailQuestion = Icons.mark_email_unread_rounded;
  static const IconData piggyBank = Icons.savings_rounded;
  static const IconData sliders = Icons.tune_rounded;
  static const IconData messageSquare = Icons.chat_bubble_rounded;
  static const IconData messageCircle = Icons.forum_rounded;
  static const IconData megaphone = Icons.campaign_rounded;
  static const IconData gitBranch = Icons.account_tree_rounded;
  static const IconData shield = Icons.shield_rounded;
  static const IconData logOut = Icons.logout_rounded;
  static const IconData menu = Icons.menu_rounded;
  static const IconData x = Icons.close_rounded;
  static const IconData plus = Icons.add_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData send = Icons.send_rounded;
  static const IconData trendingUp = Icons.trending_up_rounded;
  static const IconData filter = Icons.filter_list_rounded;
  static const IconData info = Icons.info_outline_rounded;
  static const IconData chevronRight = Icons.chevron_right_rounded;
  static const IconData chevronLeft = Icons.chevron_left_rounded;
  static const IconData chevronDown = Icons.keyboard_arrow_down_rounded;
  static const IconData externalLink = Icons.open_in_new_rounded;
  static const IconData phoneOff = Icons.phone_disabled_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData wallet = Icons.account_balance_wallet_rounded;

  // Additional icons used across screens
  static const IconData globe = Icons.language_rounded;
  static const IconData key = Icons.vpn_key_rounded;
  static const IconData slash = Icons.do_not_disturb_alt_rounded;
  static const IconData compass = Icons.explore_rounded;
  static const IconData creditCard = Icons.credit_card_rounded;
  static const IconData receipt = Icons.receipt_long_rounded;
  static const IconData link = Icons.link_rounded;
  static const IconData save = Icons.save_rounded;
  static const IconData gitFork = Icons.alt_route_rounded;
}
