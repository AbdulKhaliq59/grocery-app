import 'package:flutter/material.dart';
import 'package:grocery_app/utils/app_theme.dart';

class AnimatedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const AnimatedSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _widthAnimation = Tween<double>(begin: 50, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && widget.controller.text.isEmpty) {
        _collapse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() {
      _isExpanded = true;
    });
    _animationController.forward();
    _focusNode.requestFocus();
  }

  void _collapse() {
    setState(() {
      _isExpanded = false;
    });
    _animationController.reverse();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: (_widthAnimation.value * 100).toInt(),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: _isExpanded ? 16 : 0,
                    right: _isExpanded ? 8 : 0,
                  ),
                  child: _isExpanded
                      ? TextField(
                          controller: widget.controller,
                          focusNode: _focusNode,
                          onChanged: widget.onChanged,
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            hintStyle: TextStyle(
                              color: AppTheme.subtitleColor,
                            ),
                            border: InputBorder.none,
                            suffixIcon: widget.controller.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: AppTheme.subtitleColor,
                                    ),
                                    onPressed: () {
                                      widget.controller.clear();
                                      widget.onChanged('');
                                    },
                                  )
                                : null,
                          ),
                        )
                      : const SizedBox(),
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _isExpanded ? Colors.transparent : AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.search : Icons.search,
                    color: _isExpanded ? AppTheme.primaryColor : Colors.white,
                  ),
                  onPressed: _isExpanded ? null : _expand,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
