requires   "File::Spec";

on "configure" => sub {
    requires   "ExtUtils::MakeMaker";

    recommends "ExtUtils::MakeMaker"      => "7.78";
    };

on "test" => sub {
    requires   "Test::Fatal";
    requires   "Test::Simple"             => "0.88";
    requires   "Test:Warnings";

    recommends "Test::Simple"             => "1.302224";
    };
