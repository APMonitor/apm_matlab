% Run all example problems
cd example_hs71;
main

disp('Pause for 2 sec')
pause(2)
cd ../example_sbml_vaccine
main

disp('Pause for 2 sec')
pause(2)
cd ../example_cstr_seq;
main

disp('Pause for 2 sec')
pause(2)
cd ../example_cstr_simul;
main

disp('Pause for 2 sec')
pause(2)
cd ../example_nlc
main

disp('Pause for 2 sec')
pause(2)
cd ../example_distillation
test

disp('Pause for 2 sec')
pause(2)
cd ../example_pendulum
test

disp('Pause for 2 sec')
pause(2)
cd ../example_4tank
prbs

disp('Test completed')

