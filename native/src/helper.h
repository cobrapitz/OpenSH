#ifndef SH_HELPER_H
#define SH_HELPER_H

#include <Godot.hpp>
#include <Node.hpp>
#include <vector>
#include <map>
#include <string>

namespace godot::sh {

class Helper : public Node {
    GODOT_CLASS(Helper, Node)

private:
    std::vector<int> random_values;
    int random_it;

    std::map<std::string, int64_t> timers;
    static Helper *_singleton;

public:

    static inline Helper *get_singleton() {
		if (!Helper::_singleton) {
			Helper::_singleton = new Helper;
		}
		return Helper::_singleton;
	}

    
public:
    static void _register_methods();

    Helper();
    ~Helper();

    void _init();
    void _ready();

    int get_pseudo_random();
    int get_fixed_value_for_position(int x, int y);

    void set_timer(const String& timer_name);
    void get_time(const String& timer_name, const String& message = "");

};

}


#endif