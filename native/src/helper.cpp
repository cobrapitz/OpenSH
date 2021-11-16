#include "helper.h"

#include <OS.hpp>

using namespace godot;
using namespace godot::sh;


Helper *Helper::_singleton = nullptr;
int Helper::random_it = 0;

void Helper::_register_methods() {
    register_method("_init", &Helper::_init);
    register_method("_ready", &Helper::_ready);

    register_method("get_pseudo_random", &Helper::get_pseudo_random);
    register_method("get_fixed_value_for_position", &Helper::get_fixed_value_for_position);
    register_method("set_timer", &Helper::set_timer);
    register_method("get_time", &Helper::get_time);
}

Helper::Helper()
{

}

Helper::~Helper() {
    
}

void Helper::_init() {
    random_values = {
        1165934310, 669612565, 1424820038, 1868795075, 1940855634, 898051367, 1067670816, 1551156550, 1639847550, 106018252, 1951382077, 1077777856, 957775798, 1444661513, 1361700819, 163661895, 1441541754, 843494663, 1886753727, 929708002, 399890570, 1413156978, 1230721421, 978615599, 528192260, 809617626, 
        2050730441, 1585239794, 1869889706, 953190020, 1460899329, 930465829, 884541042, 1240859211, 257119583, 13760727, 1030178576, 303534184, 39081953, 1162109526, 442014264, 13001996, 1596448587, 1369725520, 984121976, 264456267, 1144697789, 880670563, 1119898307, 977056412, 1628336806, 
        863464975, 588032386, 2075187222, 612483302, 1916754522, 940469507, 1022269919, 1502949859, 49097677, 1938210654, 479116854, 2111170364, 712410156, 411170892, 64743945, 852469376, 398038510, 284042158, 80669883, 617322351, 1748991420, 1107105107, 1864318402, 1655196946, 209624522, 
        2063985437, 280387403, 1721722878, 1051990904, 695614564, 435994372, 1860778926, 1054527433, 1920199838, 1668807585, 185044468, 1355840676, 440762277, 91340296, 1056851303, 2106479915, 149845388, 1754993522, 2078420742, 730540045, 1220324864, 591206342, 1242092045, 1539484263, 500134710, 
        2097281562, 1503491838, 1408840812, 82514731, 2118110143, 77056488, 2011238594, 1502741861, 1644084450, 1297152632, 1790577754, 1128155123, 1712211559, 1588510544, 902326127, 2130932739, 783743451, 1217278929, 1789746899, 2053345263, 2077677550, 2066194216, 519949184, 207128069, 414503154, 
        1427422614, 2002258801, 719553860, 635318045, 645222711, 1178264623, 694130420, 1509376323, 1640372012, 417680343, 1752475664, 1111429143, 5457966, 1858173770, 661390799, 137204175, 2033112000, 1644804706, 952757164, 1415737757, 1230286723, 229938278, 1651751804, 1912360862, 1745309350, 
        219602560, 1544392077, 543835699, 1436097110, 93129540, 460015524, 215357034, 1779827218, 488261395, 464739049, 1891128889, 1870016001, 1375504288, 698241028, 2024525071, 523967891, 171973775, 1393948132, 1474241433, 798393730, 387932198, 521870215, 1614405741, 1647806137, 595423233, 
        49253952, 654721673, 628033982, 308188907, 678905977, 352479322, 1077180448, 1860281535, 1779664865, 1329677346, 1984330901, 930435987, 1898639207, 1805401418, 1511112908, 766367898, 450881110, 727910420, 1747254276, 1827638003, 1583965836, 1847907042, 942477082, 44696764,
    };
    random_it = 0;
}

void Helper::_ready() {
    
}


int Helper::get_pseudo_random() {
    return random_values[random_it++ % random_values.size()];
}

unsigned int Helper::get_fixed_value_for_position(int x, int y) {
    //https://stackoverflow.com/questions/52432739/consistent-random-number-based-on-position-not-noise-based (modified)
    return x * x * y + 2*y * y *x + random_values[int(x * x + y * y) % random_values.size()];
}

void Helper::set_timer(const String& timer_name) {
    if (timers.find(timer_name.alloc_c_string()) == timers.end()) {
        timers.insert( std::make_pair<std::string, int64_t>(timer_name.alloc_c_string(), OS::get_singleton()->get_system_time_msecs()) );
    } else {
        timers[timer_name.alloc_c_string()] = OS::get_singleton()->get_system_time_msecs();
    }
}

void Helper::get_time(const String& timer_name, const String& message) {
    if (timers.find(timer_name.alloc_c_string()) == timers.end()) {
        Godot::print("couldn't find timer with name: " + timer_name);
        return;
    }

    if (message.empty()) {
        Godot::print(timer_name + " took: " + String::num_int64(OS::get_singleton()->get_system_time_msecs() - timers[timer_name.alloc_c_string()]));
    } else {
        Godot::print(message + String::num_int64(OS::get_singleton()->get_system_time_msecs() - timers[timer_name.alloc_c_string()]));
    }

}
