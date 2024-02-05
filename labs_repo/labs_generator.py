import os
import random
import yaml
import subprocess
import sys

target_user = 'sharaf'
target_group = 'sharaf'

def random_subnet():
    """ Generate a random subnet within the 10.x.x.0/24 range. """
    return f'10.0.{random.randint(1,254)}.0/24'

def process_compose_file(student_id, compose_file, output_dir):
    with open(compose_file, 'r') as file:
        compose = yaml.safe_load(file)
        lab_number = compose_file.split('-')[0].split('/')[-1]

        # Generate a random subnet
        subnet = random_subnet()

        # Update network
        original_network_name = next(iter(compose['networks']))
        new_network_name = f'net-{student_id}'
        compose['networks'] = {
            new_network_name: {
                'ipam': {
                    'config': [{'subnet': subnet}]
                }
            }
        }

        new_services = {}
        for service in compose['services']:
            # Construct the new service name
            new_service_name = f'{student_id}-{lab_number}-{service}'

            # Copy the service configuration
            new_services[new_service_name] = compose['services'][service]

            # If you also want to update the container name to match the new service name
            new_services[new_service_name]['container_name'] = new_service_name

            # Update network configuration if present
            if 'networks' in new_services[new_service_name]:
                new_services[new_service_name]['networks'] = {
                    new_network_name: {
                       ## 'ipv4_address': random_ip(subnet)
                    }
                }

        # Replace the old services with the new services
        compose['services'] = new_services

        # Create lab-specific folder within the student's folder
        lab_folder = os.path.join(output_dir, f'{lab_number}')
        if not os.path.exists(lab_folder):
            os.makedirs(lab_folder)
            # Change ownership of the new directory
            subprocess.run(['chown', f'{target_user}:{target_group}', lab_folder], check=True)

        # Save the updated compose file in the lab-specific folder
        student_compose_file = os.path.join(lab_folder, f'{student_id}_compose.yaml')
        with open(student_compose_file, 'w') as output_file:
            yaml.dump(compose, output_file, default_flow_style=False, sort_keys=False)
            # Change ownership of the new file
            subprocess.run(['chown', f'{target_user}:{target_group}', student_compose_file], check=True)
            # Add a volume directory in the same folder
            volume_dir = os.path.join(lab_folder, 'volumes')
            if not os.path.exists(volume_dir):
                os.makedirs(volume_dir)
                # Change ownership of the new directory
                subprocess.run(['chown', f'{target_user}:{target_group}', volume_dir], check=True)

def random_ip(subnet):
    """ Generate a random IP address within the specified subnet. """
    subnet_parts = subnet.split('.')
    return f'{subnet_parts[0]}.{subnet_parts[1]}.{subnet_parts[2]}.{random.randint(1,254)}'

def main(student_id):
    compose_folder = '/home/sharaf/CyberRange_v2/labs_repo/'  # Path to the folder containing the compose files
    student_path = os.path.join('/home/sharaf/CyberRange_v2/Students', student_id, "Labs")  # Student's directory
    if not os.path.exists(student_path):
        print(f"Error: Student directory for {student_id} does not exist.")
        sys.exit(1)

    for compose_file in os.listdir(compose_folder):
        if compose_file.startswith('lab') and compose_file.endswith('.yaml'):
            process_compose_file(student_id, os.path.join(compose_folder, compose_file), student_path)  
    

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python script.py <StudentID>")
        sys.exit(1)

    main(sys.argv[1])
